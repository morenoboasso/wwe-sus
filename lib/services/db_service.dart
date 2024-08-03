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

  Future<void> createMatchCard(String payperview, String title, String type, List<String> participants) async {
    try {
      await _firestore.collection('match_cards').add({
        'payperview': payperview,
        'title': title,
        'type': type,
        'participants': participants,
      });
    } catch (e) {
      debugPrint('Error creating match card: $e');
    }
  }

  Future<void> voteForWrestler(String matchId, String userName, String wrestler) async {
    try {
      await _firestore.collection('votes').add({
        'matchId': matchId,
        'userName': userName,
        'wrestler': wrestler,
      });
    } catch (e) {
      debugPrint('Error voting for wrestler: $e');
    }
  }

  Future<void> setMatchResult(String matchId, String winner) async {
    try {
      await _firestore.collection('match_cards').doc(matchId).update({
        'winner': winner,
      });
    } catch (e) {
      debugPrint('Error setting match result: $e');
    }
  }
}
