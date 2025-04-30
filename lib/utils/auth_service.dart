import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool get isAuthenticated => _auth.currentUser != null;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static String? get userId => _auth.currentUser?.uid;
}
