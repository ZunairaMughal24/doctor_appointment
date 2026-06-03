import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUpPatient({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> signUpDoctor({
    required String name,
    required String email,
    required String password,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
  });
  Future<UserModel> registerAsDoctor({
    required String uid,
    required String name,
    required String email,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
  });
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? speciality,
    String? experience,
    String? phoneNumber,
    String? location,
    String? availability,
    String? services,
    String? description,
  });
  Future<void> switchRole({required String uid, required UserRole role});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  // Reads the persisted currentRole from the users doc.
  // Falls back to natural role (doctor if hasDoctorProfile, else patient).
  UserRole _resolveRole(DocumentSnapshot<Map<String, dynamic>> userDoc, bool hasDoctorProfile) {
    if (userDoc.exists) {
      final saved = userDoc.data()?['currentRole'] as String?;
      if (saved == 'doctor' && hasDoctorProfile) return UserRole.doctor;
      if (saved == 'patient') return UserRole.patient;
    }
    return hasDoctorProfile ? UserRole.doctor : UserRole.patient;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      try {
        final doctorDoc = await firestore.collection('doctors').doc(uid).get();
        final userDoc = await firestore.collection('users').doc(uid).get();

        final hasDoctorProfile = doctorDoc.exists;
        final savedRole = _resolveRole(userDoc, hasDoctorProfile);

        if (doctorDoc.exists) {
          final data = doctorDoc.data()!;
          return UserModel(
            uid: uid,
            name: data['name'] ?? email,
            email: data['email'] ?? email,
            role: savedRole,
            hasDoctorProfile: true,
          );
        }
        if (userDoc.exists) {
          final data = userDoc.data()!;
          return UserModel(
            uid: uid,
            name: data['name'] ?? email,
            email: data['email'] ?? email,
            role: savedRole,
            hasDoctorProfile: hasDoctorProfile,
          );
        }
      } catch (_) {
        // Firestore permission error — auth succeeded, default to patient
      }

      return UserModel(
        uid: uid,
        name: credential.user?.displayName ?? email,
        email: email,
        role: UserRole.patient,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed.');
    }
  }

  @override
  Future<UserModel> signUpPatient({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final model = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: UserRole.patient,
      );
      try {
        await firestore.collection('users').doc(uid).set(model.toFirestore());
      } catch (_) {}
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed.');
    }
  }

  @override
  Future<UserModel> signUpDoctor({
    required String name,
    required String email,
    required String password,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await firestore.collection('doctors').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'doctor',
        'speciality': speciality,
        'experience': experience,
        'number': phoneNumber,
        'location': location,
        'availability': availability,
        'services': services,
        'description': '',
        'rating': 4.5,
        'isSeed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserModel(
        uid: uid,
        name: name,
        email: email,
        role: UserRole.doctor,
        hasDoctorProfile: true,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Doctor sign up failed.');
    }
  }

  @override
  Future<UserModel> registerAsDoctor({
    required String uid,
    required String name,
    required String email,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
  }) async {
    try {
      await firestore.collection('doctors').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'doctor',
        'speciality': speciality,
        'experience': experience,
        'number': phoneNumber,
        'location': location,
        'availability': availability,
        'services': services,
        'description': '',
        'rating': 4.5,
        'isSeed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserModel(
        uid: uid,
        name: name,
        email: email,
        role: UserRole.doctor,
        hasDoctorProfile: true,
      );
    } catch (e) {
      throw AuthException('Failed to register as doctor: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? speciality,
    String? experience,
    String? phoneNumber,
    String? location,
    String? availability,
    String? services,
    String? description,
  }) async {
    try {
      final batch = firestore.batch();
      final userRef = firestore.collection('users').doc(uid);
      final doctorRef = firestore.collection('doctors').doc(uid);

      batch.set(userRef, {'name': name, 'email': email}, SetOptions(merge: true));

      final doctorDoc = await doctorRef.get();
      if (doctorDoc.exists) {
        // Map the editable professional fields onto the doctors document,
        // omitting any that weren't provided. ('number' is the stored key.)
        final doctorData = <String, dynamic>{'name': name, 'email': email};
        void put(String key, String? value) {
          if (value != null) doctorData[key] = value;
        }

        put('speciality', speciality);
        put('experience', experience);
        put('number', phoneNumber);
        put('location', location);
        put('availability', availability);
        put('services', services);
        put('description', description);

        batch.set(doctorRef, doctorData, SetOptions(merge: true));
      }
      await batch.commit();

      final hasDoctorProfile = doctorDoc.exists;
      return UserModel(
        uid: uid,
        name: name,
        email: email,
        role: hasDoctorProfile ? UserRole.doctor : UserRole.patient,
        hasDoctorProfile: hasDoctorProfile,
      );
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> switchRole({required String uid, required UserRole role}) async {
    await firestore
        .collection('users')
        .doc(uid)
        .set({'currentRole': role.name}, SetOptions(merge: true));
  }

  @override
  Future<void> signOut() => firebaseAuth.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    final uid = firebaseUser.uid;

    try {
      final doctorDoc = await firestore.collection('doctors').doc(uid).get();
      final userDoc = await firestore.collection('users').doc(uid).get();

      final hasDoctorProfile = doctorDoc.exists;
      final savedRole = _resolveRole(userDoc, hasDoctorProfile);

      if (doctorDoc.exists) {
        return UserModel.fromFirestore(
          doctorDoc.data()!,
          uid,
          hasDoctorProfile: true,
          roleOverride: savedRole,
        );
      }
      if (userDoc.exists) {
        return UserModel.fromFirestore(
          userDoc.data()!,
          uid,
          hasDoctorProfile: false,
          roleOverride: savedRole,
        );
      }
    } catch (_) {
      return UserModel(
        uid: uid,
        name: firebaseUser.displayName ?? firebaseUser.email ?? '',
        email: firebaseUser.email ?? '',
        role: UserRole.patient,
      );
    }
    return null;
  }
}
