import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase/firebase_firestore_service.dart';

class AdminUserService {
  AdminUserService({FirebaseFirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirebaseFirestoreService();

  final FirebaseFirestoreService _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> resetAllUsersPoints() async {
    final snapshot = await _usersCollection.get();
    if (snapshot.docs.isEmpty) return;

    WriteBatch batch = _firestore.instance.batch();
    var opCount = 0;

    Future<void> commitIfNeeded() async {
      if (opCount == 0) return;
      await batch.commit();
      batch = _firestore.instance.batch();
      opCount = 0;
    }

    for (final doc in snapshot.docs) {
      batch.set(doc.reference, {
        'points': 0,
        'seasonPoints': 0,
        'correctPredictions': 0,
        'seasonCorrectPredictions': 0,
        'wrongPredictions': 0,
        'seasonWrongPredictions': 0,
        'streak': 0,
        'seasonStreak': 0,
        'accuracy': 0.0,
        'seasonAccuracy': 0.0,
      }, SetOptions(merge: true));

      opCount += 1;
      if (opCount >= 450) {
        await commitIfNeeded();
      }
    }

    await commitIfNeeded();
  }
}
