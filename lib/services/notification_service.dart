import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // حفظ إنذار الطوارئ وتجهيز إشعار للطبيب في Firestore.
  Future<void> sendEmergencyAlert({
    required String doctorId,
    required String patientName,
    required String patientId,
    required String symptom,
  }) async {
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('emergency_alerts').add(<String, dynamic>{
      'doctorId': doctorId,
      'patientName': patientName,
      'patientId': patientId,
      'symptom': symptom,
      'timestamp': timestamp,
      'isRead': false,
    });

    final doctorSnapshot = await _firestore.collection('doctors').doc(doctorId).get();
    final token = doctorSnapshot.data()?['fcmToken']?.toString();
    if (token == null || token.isEmpty) return;

    await _firestore.collection('notifications_queue').add(<String, dynamic>{
      'token': token,
      'title': '🚨 تحذير طارئ - $patientName',
      'body': 'المريض يعاني من: $symptom',
      'timestamp': timestamp,
    });
  }
}
