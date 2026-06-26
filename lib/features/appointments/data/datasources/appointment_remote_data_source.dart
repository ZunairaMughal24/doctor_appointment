import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<void> bookAppointment(AppointmentModel appointment);
  Future<List<AppointmentModel>> getUserAppointments(String patientId);
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId);

  /// Updates an appointment's [status] and fires the matching notification.
  /// [actorIsDoctor] decides who is notified on a cancellation.
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
    required bool actorIsDoctor,
  });

  /// Writes the patient's rating to the appointment doc and recalculates the
  /// doctor's average rating atomically in a single Firestore transaction.
  Future<void> submitRating({
    required String appointmentId,
    required String doctorId,
    required int rating,
    required String comment,
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;

  const AppointmentRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _appointments =>
      firestore.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _slots =>
      firestore.collection('booked_slots');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      firestore.collection('notifications');

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    try {
      await firestore.runTransaction((txn) async {
        // Slot lock: a deterministic doc id guarantees only one booking can win
        // a given doctor+date+time, even under concurrent requests.
        DocumentReference<Map<String, dynamic>>? slotRef;
        if (appointment.appointmentTime.isNotEmpty) {
          slotRef = _slots.doc(_slotId(
            appointment.doctorId,
            appointment.appointmentDate,
            appointment.appointmentTime,
          ));
          final slotSnap = await txn.get(slotRef); // read before any write
          if (slotSnap.exists) {
            throw const ServerException(
                'That time slot was just booked. Please pick another.');
          }
        }

        final apptRef = _appointments.doc();
        txn.set(apptRef, appointment.toFirestore());

        if (slotRef != null) {
          txn.set(slotRef, {
            'doctor_id': appointment.doctorId,
            'date': appointment.appointmentDate,
            'time': appointment.appointmentTime,
            'appointment_id': apptRef.id,
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        // Notify the doctor of the incoming request.
        txn.set(
          _notifications.doc(),
          NotificationModel.payload(
            userId: appointment.doctorId,
            title: 'New appointment request',
            body:
                'New appointment request from ${appointment.patientName} for '
                '${appointment.appointmentDate} at ${_to12h(appointment.appointmentTime)}.',
            type: AppNotificationType.booked,
            appointmentId: apptRef.id,
          ),
        );
      });
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getUserAppointments(String patientId) =>
      _query('appointment_by_id', patientId);

  @override
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) =>
      _query('appointment_with_id', doctorId);

  /// Shared query + newest-first client-side sort (avoids a composite index
  /// that a server-side `orderBy` on top of the `where` would require).
  Future<List<AppointmentModel>> _query(String field, String value) async {
    try {
      final snapshot = await _appointments.where(field, isEqualTo: value).get();
      final items = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
          .toList()
        ..sort((a, b) {
          final at = a.createdAt, bt = b.createdAt;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });
      return items;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
    required bool actorIsDoctor,
  }) async {
    try {
      final apptRef = _appointments.doc(appointmentId);
      final snap = await apptRef.get();
      if (!snap.exists) {
        throw const ServerException('Appointment not found.');
      }
      final data = snap.data()!;
      final doctorId = (data['appointment_with_id'] ?? '') as String;
      final patientId = (data['appointment_by_id'] ?? '') as String;
      final doctorName = (data['appointment_with_name'] ?? '') as String;
      final patientName = (data['appointment_by_name'] ?? '') as String;
      final date = (data['appointment_date'] ?? '') as String;
      final time = (data['appointment_time'] ?? '') as String;

      final batch = firestore.batch();
      batch.update(apptRef, {'status': status.key});

      // Cancelling frees the slot lock so the time becomes bookable again.
      if (status == AppointmentStatus.cancelled && time.isNotEmpty) {
        batch.delete(_slots.doc(_slotId(doctorId, date, time)));
      }

      // Fire the appropriate notification to the other party.
      if (status == AppointmentStatus.confirmed) {
        batch.set(
          _notifications.doc(),
          NotificationModel.payload(
            userId: patientId,
            title: 'Appointment confirmed',
            body: 'Your appointment with $doctorName is confirmed for '
                '$date at ${_to12h(time)}.',
            type: AppNotificationType.confirmed,
            appointmentId: appointmentId,
          ),
        );
      } else if (status == AppointmentStatus.cancelled) {
        final body = actorIsDoctor
            ? 'Your appointment with $doctorName on $date at ${_to12h(time)} was cancelled.'
            : '$patientName cancelled their appointment on $date at ${_to12h(time)}.';
        batch.set(
          _notifications.doc(),
          NotificationModel.payload(
            userId: actorIsDoctor ? patientId : doctorId,
            title: 'Appointment cancelled',
            body: body,
            type: AppNotificationType.cancelled,
            appointmentId: appointmentId,
          ),
        );
      }

      await batch.commit();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> submitRating({
    required String appointmentId,
    required String doctorId,
    required int rating,
    required String comment,
  }) async {
    try {
      await firestore.runTransaction((txn) async {
        final doctorRef = firestore.collection('doctors').doc(doctorId);
        final doctorSnap = await txn.get(doctorRef);
        final doctorData = doctorSnap.data() ?? {};

        final currentCount = (doctorData['rating_count'] as int?) ?? 0;
        final currentTotal =
            (doctorData['rating_total'] as num?)?.toDouble() ?? 0.0;
        final newCount = currentCount + 1;
        final newTotal = currentTotal + rating;
        final newAverage =
            double.parse((newTotal / newCount).toStringAsFixed(1));

        txn.update(_appointments.doc(appointmentId), {
          'rating': rating,
          'rating_comment': comment,
          'rated_at': FieldValue.serverTimestamp(),
        });

        txn.update(doctorRef, {
          'rating': newAverage,
          'rating_count': newCount,
          'rating_total': newTotal,
        });
      });
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Deterministic slot id. Strips '/' and ':' which aren't valid in doc ids.
  String _slotId(String doctorId, String date, String time) =>
      '${doctorId}_${date.replaceAll('/', '-')}_${time.replaceAll(':', '-')}';

  /// '14:30' → '2:30 PM' for friendly notification copy.
  String _to12h(String hhmm) {
    if (hhmm.isEmpty) return '';
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }
}
