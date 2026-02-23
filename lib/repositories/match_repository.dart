import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';
import '../services/firebase/firebase_firestore_service.dart';

class MatchRepository {
  MatchRepository({FirebaseFirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirebaseFirestoreService();

  final FirebaseFirestoreService _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('matches');

  Future<List<Match>> fetchMatches({bool onlyOpen = false}) async {
    Query<Map<String, dynamic>> query = _collection.orderBy('createdAt', descending: true);
    if (onlyOpen) {
      query = query.where('status', isEqualTo: MatchStatus.open.value);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Match.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Match>> watchMatches({bool onlyOpen = false}) {
    Query<Map<String, dynamic>> query = _collection.orderBy('createdAt', descending: true);
    if (onlyOpen) {
      query = query.where('status', isEqualTo: MatchStatus.open.value);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Match.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> createMatch(Match match) async {
    await _collection.doc(match.id).set(match.toMap());
  }

  Future<void> updateMatch(String matchId, Map<String, dynamic> data) async {
    await _collection.doc(matchId).update(data);
  }

  Future<void> deleteMatch(String matchId) async {
    await _collection.doc(matchId).delete();
  }
}
