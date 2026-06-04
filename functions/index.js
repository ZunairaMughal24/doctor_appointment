const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Looks up an FCM token for a uid. Patient tokens live on the users doc and
 * doctor tokens on the doctors doc; we check users first, then fall back to
 * doctors so either kind of recipient resolves.
 */
async function getFcmToken(db, uid) {
    if (!uid) return null;
    const userDoc = await db.collection("users").doc(uid).get();
    if (userDoc.exists && userDoc.data().fcmToken) {
        return userDoc.data().fcmToken;
    }
    const doctorDoc = await db.collection("doctors").doc(uid).get();
    if (doctorDoc.exists && doctorDoc.data().fcmToken) {
        return doctorDoc.data().fcmToken;
    }
    return null;
}

/**
 * Builds a high-importance message. `channelId` matches the Android channel the
 * app creates (high_importance_channel) so background notifications show as a
 * heads-up. All `data` values must be strings.
 */
function buildMessage(token, title, body, data) {
    return {
        token: token,
        notification: {title: title, body: body},
        android: {
            priority: "high",
            notification: {
                channelId: "high_importance_channel",
                sound: "default",
            },
        },
        apns: {payload: {aps: {sound: "default"}}},
        data: Object.assign({click_action: "FLUTTER_NOTIFICATION_CLICK"}, data),
    };
}

/**
 * Sends a push when an appointment is booked or its status changes.
 * Notifies both the patient and the doctor.
 */
exports.sendAppointmentNotification = functions.firestore
    .document("appointments/{appointmentId}")
    .onWrite(async (change, context) => {
        const appointmentId = context.params.appointmentId;
        const beforeData = change.before.exists ? change.before.data() : null;
        const afterData = change.after.exists ? change.after.data() : null;

        // Document was deleted — nothing to notify.
        if (!afterData) {
            console.log(`Appointment ${appointmentId} was deleted.`);
            return null;
        }

        // Field names match the Firestore schema written by AppointmentModel.
        const patientId = afterData.appointment_by_id;
        const doctorId = afterData.appointment_with_id;
        const status = afterData.status;
        const date = afterData.appointment_date;
        const time = afterData.appointment_time;

        let title = "Appointment Update";
        let body = `Your appointment status is now ${status}.`;

        if (!beforeData) {
            title = "New Appointment Booked";
            body = `A new appointment has been booked for ${date} at ${time}.`;
        } else if (beforeData.status !== status) {
            title = "Appointment Status Changed";
            body = `Appointment on ${date} at ${time} is now ` +
                `${(status || "").toUpperCase()}.`;
        } else {
            // No booking or status change (e.g. a description edit) — skip.
            return null;
        }

        const db = admin.firestore();

        try {
            const [patientFcm, doctorFcm] = await Promise.all([
                getFcmToken(db, patientId),
                getFcmToken(db, doctorId),
            ]);

            const data = {appointmentId: appointmentId, type: "booking"};
            const sends = [];

            if (patientFcm) {
                sends.push(
                    admin.messaging()
                        .send(buildMessage(patientFcm, title, body, data))
                        .then(() => console.log(`Notified patient ${patientId}`))
                        .catch((err) => console.error("Patient send failed:", err)),
                );
            }
            if (doctorFcm) {
                sends.push(
                    admin.messaging()
                        .send(buildMessage(doctorFcm, title, body, data))
                        .then(() => console.log(`Notified doctor ${doctorId}`))
                        .catch((err) => console.error("Doctor send failed:", err)),
                );
            }

            await Promise.all(sends);
        } catch (error) {
            console.error("Error in appointment notification function:", error);
        }

        return null;
    });

/**
 * Sends a push for reminder notifications. The app writes a `reminder` doc into
 * the `notifications` collection (e.g. a day-of reminder); this delivers it to
 * the recipient's device so it arrives even when the app is closed.
 */
exports.sendReminderNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, context) => {
        const data = snap.data();
        // Only reminders push here. Booking/confirm/cancel events are delivered
        // by sendAppointmentNotification, so this avoids double notifications.
        if (!data || data.type !== "reminder") return null;

        const userId = data.user_id;
        if (!userId) return null;

        const db = admin.firestore();
        try {
            const token = await getFcmToken(db, userId);
            if (!token) {
                console.log(`No FCM token for reminder recipient ${userId}.`);
                return null;
            }
            await admin.messaging().send(buildMessage(
                token,
                data.title || "Appointment Reminder",
                data.body || "You have an upcoming appointment.",
                {
                    appointmentId: data.appointment_id || "",
                    type: "reminder",
                },
            ));
            console.log(`Reminder sent to ${userId}.`);
        } catch (error) {
            console.error("Error in reminder notification function:", error);
        }

        return null;
    });
