import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

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

  Future<void> saveUserSelection(String matchId, String selectedWrestler) async {
    final userName = _storage.read('userName');

    if (userName != null) {
      try {
        await _firestore.collection('userSelections').add({
          'userName': userName,
          'matchId': matchId,
          'selectedWrestler': selectedWrestler,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error saving user selection: $e');
      }
    } else {
      debugPrint('No user name found in storage.');
    }
  }

  // Nuovo metodo per ottenere la selezione dell'utente
  Future<String?> getUserSelection(String matchId) async {
    final userName = _storage.read('userName');

    if (userName != null) {
      try {
        final querySnapshot = await _firestore
            .collection('userSelections')
            .where('userName', isEqualTo: userName)
            .where('matchId', isEqualTo: matchId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first['selectedWrestler'] as String?;
        }
      } catch (e) {
        debugPrint('Error getting user selection: $e');
      }
    }

    return null;
  }

  Future<int> getVoteCount(String matchId) async {
    try {
      final querySnapshot = await _firestore
          .collection('userSelections')
          .where('matchId', isEqualTo: matchId)
          .get();

      return querySnapshot.size;
    } catch (e) {
      debugPrint('Error getting vote count: $e');
      return 0;
    }
  }
}
