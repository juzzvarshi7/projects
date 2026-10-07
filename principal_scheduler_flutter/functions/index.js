const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

function formatVoiceText(appt, newStatus) {
  const staffName = appt.staff_name || 'Staff';
  const principalName = appt.principal_name || 'Principal';
  const title = appt.title || 'your appointment';
  const reqDt = appt.requested_datetime || '';
  if (newStatus === 'accepted') {
    return `${title} scheduled for ${reqDt} has been accepted by ${principalName}.`;
  } else if (newStatus === 'declined') {
    return `${title} scheduled for ${reqDt} has been declined by ${principalName}.`;
  } else if (newStatus === 'suggested') {
    const suggested = appt.suggested_datetime || 'a suggested time';
    return `${principalName} suggested a new time: ${suggested} for ${title}.`;
  } else {
    return `Update on ${title}: status is now ${newStatus}.`;
  }
}

exports.onAppointmentUpdate = functions.firestore
  .document('appointments/{apptId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};
    const apptId = context.params.apptId;

    const prevStatus = (before.status || '').toString().toLowerCase();
    const newStatus = (after.status || '').toString().toLowerCase();

    if (prevStatus === newStatus) {
      console.log(`[${apptId}] status did not change (${prevStatus}). Ignoring.`);
      return null;
    }

    const interesting = ['accepted', 'declined', 'suggested'];
    if (!interesting.includes(newStatus)) {
      console.log(`[${apptId}] new status ${newStatus} not interesting. Ignoring.`);
      return null;
    }

    if (after.notification_sent === true) {
      console.log(`[${apptId}] notification_sent already true. Ignoring duplicate.`);
      return null;
    }

    const staffUid = after.staff_uid || after.staff_id || null;
    if (!staffUid) {
      console.error(`[${apptId}] No staff_uid/staff_id found in appointment doc, cannot send notification.`);
      return null;
    }

    const userDocRef = admin.firestore().collection('users').doc(String(staffUid));
    const userSnap = await userDocRef.get();
    if (!userSnap.exists) {
      console.error(`[${apptId}] staff user doc (${staffUid}) not found.`);
      return null;
    }
    const userData = userSnap.data() || {};
    const fcmToken = userData.fcmToken || userData.fcm_token || null;
    if (!fcmToken) {
      console.error(`[${apptId}] staff fcm token not available for user ${staffUid}.`);
      return null;
    }

    const title = `Appointment ${newStatus.toUpperCase()}`;
    const body = after.notification_text || formatVoiceText(after, newStatus);
    const voiceText = after.voice_text || body;

    const message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: 'decision',
        apptId: String(apptId),
        status: newStatus,
        voice_text: voiceText,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'principal_scheduler_channel',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            alert: {
              title: title,
              body: body,
            },
          },
        },
      },
    };

    try {
      const resp = await admin.messaging().send(message);
      console.log(`[${apptId}] FCM sent: ${resp}`);

      await change.after.ref.update({
        notification_sent: true,
        notification_sent_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`[${apptId}] Marked notification_sent = true`);
      return null;
    } catch (err) {
      console.error(`[${apptId}] Error sending FCM:`, err);
      await change.after.ref.update({
        last_notification_error: typeof err === 'string' ? err : (err.message || JSON.stringify(err)),
        notification_attempted_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      return null;
    }
  });
