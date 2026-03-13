import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/season_model.dart';
import '../services/firebase/firebase_firestore_service.dart';

class SeasonRepository {
  SeasonRepository({FirebaseFirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirebaseFirestoreService();

  final FirebaseFirestoreService _firestore;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection('seasons');

  Future<List<Season>> fetchSeasons({bool onlyClosed = false}) async {
    Query<Map<String, dynamic>> query = _collection.orderBy('startAt', descending: true);
    if (onlyClosed) {
      query = query.where('isClosed', isEqualTo: true);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Season.fromMap(doc.id, doc.data())).toList();
  }

  Future<Season?> fetchLatestOpenSeason() async {
    try {
      final snapshot = await _collection
          .where('isClosed', isEqualTo: false)
          .orderBy('startAt', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Season.fromMap(doc.id, doc.data());
    } catch (_) {
      // Fallback senza orderBy (evita errori di indice) e seleziona lato client
      final snapshot = await _collection.where('isClosed', isEqualTo: false).get();
      if (snapshot.docs.isEmpty) return null;
      final docs = snapshot.docs
          .map((doc) => Season.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => b.startAt.compareTo(a.startAt));
      return docs.first;
    }
  }

  Future<void> upsertSeason(Season season) {
    return _collection.doc(season.id).set(season.toMap(), SetOptions(merge: true));
  }

  Future<void> closeSeason(Season season) {
    return _collection.doc(season.id).set(
      season.copyWith(isClosed: true).toMap(),
      SetOptions(merge: true),
    );
  }
}
