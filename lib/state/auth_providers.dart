import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/firebase/firebase_auth_service.dart';

/// Provider per FirebaseAuthService
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider per UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return UserRepository(authService: authService);
});

/// Provider per lo stato di autenticazione Firebase
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges();
});

/// Provider combinato per AppUser corrente (basato su Firebase user)
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUserAsync = ref.watch(firebaseUserProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return firebaseUserAsync.when(
    data: (firebaseUser) async* {
      if (firebaseUser == null) {
        yield null;
        return;
      }
      // Ascolta i cambiamenti dell'AppUser
      await for (final appUser in userRepo.watchCurrentUser()) {
        yield appUser;
      }
    },
    loading: () async* {
      yield null;
    },
    error: (error, stack) async* {
      yield null;
    },
  );
});

/// Provider per verificare se l'utente corrente è admin
final isAdminProvider = Provider<bool>((ref) {
  final appUserAsync = ref.watch(appUserProvider);
  return appUserAsync.maybeWhen(
    data: (appUser) => appUser?.role == AppUserRole.admin,
    orElse: () => false,
  );
});

/// Provider per il ruolo dell'utente corrente
final userRoleProvider = Provider<AppUserRole>((ref) {
  final appUserAsync = ref.watch(appUserProvider);
  return appUserAsync.maybeWhen(
    data: (appUser) => appUser?.role ?? AppUserRole.user,
    orElse: () => AppUserRole.user,
  );
});
