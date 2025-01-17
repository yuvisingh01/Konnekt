import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  User? get user {
    return _user;
  }

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authStateChangeStreamListener);
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _user = credential.user;
        return true;
      }
    } catch (error) {
      print(error);
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _user = credential.user;
        return true;
      }
    } catch (error) {
      print(error);
    }
    return false;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (error) {
      print(error);
    }
    return false;
  }

  void authStateChangeStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
}
