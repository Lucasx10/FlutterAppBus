import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  signUp({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      // Criação do usuário no Firebase Authentication
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Criação do documento do usuário no Firestore
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nome': nome,
        'email': email,
        'dataCadastro': FieldValue.serverTimestamp(),
      });

      // Atualizando o nome de exibição do usuário no Firebase Authentication
      await userCredential.user!.updateDisplayName(nome);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Já existe uma conta com esse e-mail.');
      }
    } catch (e) {
      print("Error: $e");
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
