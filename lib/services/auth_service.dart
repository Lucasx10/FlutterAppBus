import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp({
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
      return null; // Cadastro bem-sucedido
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // E-mail já está em uso
        return 'Já existe uma conta com esse e-mail.';
      }
      print("Erro de autenticação: ${e.message}");
      return 'Erro de autenticação: ${e.message}';
    } catch (e) {
      print("Erro inesperado: $e");
      return 'Erro inesperado: $e';
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

  // Novo método para pegar o nome do usuário
  Future<String> getUserName() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && user.displayName != null) {
      return user.displayName!; // Retorna o nome do usuário
    } else {
      return 'Usuário não encontrado'; // Caso o nome não esteja disponível
    }
  }
}
