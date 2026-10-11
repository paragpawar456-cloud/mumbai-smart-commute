import 'package:firebase_auth/firebase_auth.dart';

/// The minimum the app needs to know about a signed-in user.
/// Passwords and tokens never leave Firebase or get written to the Sheet.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
  final String? displayName;
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);
  final String code;
  @override
  String toString() => 'AuthFailure($code)';
}

abstract interface class AuthRepository {
  bool get isAvailable;
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<String?> idToken();
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password, String name);
  Future<void> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<void> deleteAccount();
}

/// Used when the build has no Firebase config, so the app still runs in
/// guest mode instead of crashing.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  bool get isAvailable => false;
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(null);
  @override
  AppUser? get currentUser => null;
  @override
  Future<String?> idToken() async => null;

  Never _unavailable() => throw const AuthFailure('auth-unavailable');

  @override
  Future<void> signInWithEmail(String email, String password) async =>
      _unavailable();
  @override
  Future<void> registerWithEmail(String e, String p, String n) async =>
      _unavailable();
  @override
  Future<void> signInWithGoogle() async => _unavailable();
  @override
  Future<void> sendPasswordReset(String email) async => _unavailable();
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async => _unavailable();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  bool get isAvailable => true;

  AppUser? _map(User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          email: u.email,
          emailVerified: u.emailVerified,
          displayName: u.displayName,
        );

  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken();

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.code);
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(
        () => _auth.signInWithEmailAndPassword(
            email: email.trim(), password: password),
      );

  @override
  Future<void> registerWithEmail(String email, String password, String name) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        await cred.user?.updateDisplayName(name.trim());
        await cred.user?.sendEmailVerification();
      });

  @override
  Future<void> signInWithGoogle() =>
      _guard(() => _auth.signInWithProvider(GoogleAuthProvider()));

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() =>
      _guard(() async => _auth.currentUser?.delete());
}
