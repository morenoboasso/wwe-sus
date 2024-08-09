import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUserNameExists(String userName) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: userName)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking username: $e');
      return false;
    }
  }

  Future<void> createMatchCard(String payperview, String title, String type, List<String> wrestlers) async {
    try {
      await _firestore.collection('matchCards').add({
        'payperview': payperview,
        'title': title,
        'type': type,
        'wrestlers': wrestlers,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating match card: $e');
    }
  }
}
