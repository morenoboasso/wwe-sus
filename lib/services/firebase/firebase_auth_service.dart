import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper di convenienza sopra [FirebaseAuth] per centralizzare la logica
/// di autenticazione (anonima per ora).
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<User?> userChanges() => _auth.userChanges();

  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> signOut() => _auth.signOut();
}
