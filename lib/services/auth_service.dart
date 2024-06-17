import 'package:firebase_auth/firebase_auth.dart';

class SignUpService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  signUp(
      {required String nome,
      required String email,
      required String senha}) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await userCredential.user!.updateDisplayName(nome);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Já existe uma conta com esse e-mail.');
      }
    } catch (e) {
      print(e);
    }
  }
}

class LoginService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> login({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
