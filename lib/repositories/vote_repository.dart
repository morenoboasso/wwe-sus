import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vote_model.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firebase_firestore_service.dart';

class VoteRepository {
  VoteRepository({
    FirebaseAuthService? authService,
    FirebaseFirestoreService? firestoreService,
  })  : _auth = authService ?? FirebaseAuthService(),
        _firestore = firestoreService ?? FirebaseFirestoreService();

  final FirebaseAuthService _auth;
  final FirebaseFirestoreService _firestore;

  CollectionReference<Map<String, dynamic>> _votesCollection(String matchId) {
    return _firestore.collection('votes/$matchId/userVotes');
  }

  Future<List<Vote>> fetchMatchVotes(String matchId) async {
    final snapshot = await _votesCollection(matchId).get();
    return snapshot.docs
        .map((doc) => Vote.fromMap(matchId: matchId, userId: doc.id, data: doc.data()))
        .toList();
  }

  Future<Vote?> getCurrentUserVote(String matchId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _votesCollection(matchId).doc(user.uid).get();
    final data = doc.data();
    if (data == null) return null;

    return Vote.fromMap(matchId: matchId, userId: doc.id, data: data);
  }

  Stream<Vote?> watchCurrentUserVote(String matchId) {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _votesCollection(matchId).doc(user.uid).snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return null;
        return Vote.fromMap(matchId: matchId, userId: doc.id, data: data);
      });
    });
  }

  Future<void> submitVote(
    String matchId,
    Vote vote,
  ) async {
    await _votesCollection(matchId).doc(vote.userId).set(vote.toMap());
  }

  Future<void> submitVoteData(String matchId, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _votesCollection(matchId).doc(user.uid);
    final existing = await docRef.get();
    if (existing.exists) return;
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> deleteVote(String matchId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _votesCollection(matchId).doc(user.uid).delete();
  }
}
