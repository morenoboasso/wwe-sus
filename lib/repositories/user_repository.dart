import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firebase_firestore_service.dart';

class UserRepository {
  UserRepository({
    FirebaseAuthService? authService,
    FirebaseFirestoreService? firestoreService,
  })  : _auth = authService ?? FirebaseAuthService(),
        _firestore = firestoreService ?? FirebaseFirestoreService();

  final FirebaseAuthService _auth;
  final FirebaseFirestoreService _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<AppUser?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    final data = doc.data();
    if (data == null) return null;
    return AppUser.fromMap(doc.id, data);
  }

  Stream<AppUser?> watchUserById(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return AppUser.fromMap(doc.id, data);
    });
  }

  Stream<AppUser?> watchUserByName(String name) {
    return _usersCollection.where('name', isEqualTo: name).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return AppUser.fromMap(doc.id, data);
    });
  }

  Future<List<AppUser>> fetchAllUsers({
    String orderBy = 'points',
    bool descending = true,
  }) async {
    final query = _usersCollection.orderBy(orderBy, descending: descending);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AppUser.fromMap(doc.id, data);
    }).toList();
  }

  Future<AppUser?> getCurrentUserOnce() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _usersCollection.doc(firebaseUser.uid).get();
    final data = doc.data();
    if (data == null) return null;
    return AppUser.fromMap(doc.id, data);
  }

  Stream<AppUser?> watchCurrentUser() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      return _usersCollection.doc(firebaseUser.uid).snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return null;
        return AppUser.fromMap(doc.id, data);
      });
    });
  }

  Future<void> upsertUser(AppUser user) {
    return _usersCollection.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }
}
