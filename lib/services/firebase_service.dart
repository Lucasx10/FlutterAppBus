import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final String userId;

  FirebaseService(this.userId);

   // Função para verificar se o cartão já está vinculado a outro usuário
  Future<bool> isCardLinked(String cardCode) async {
    try {
      // Passo 1: Obter todos os usuários
      QuerySnapshot usuariosSnapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();

      // Passo 2: Iterar sobre os usuários e verificar se algum cartão já possui esse código
      for (var userDoc in usuariosSnapshot.docs) {
        // Passo 3: Consultar a subcoleção 'cartao' de cada usuário
        QuerySnapshot cartaoSnapshot =
            await userDoc.reference.collection('cartao').get();

        for (var cardDoc in cartaoSnapshot.docs) {
          // Verifica se o cartão tem o mesmo ID
          if (cardDoc.id == cardCode) {
            return true; // Cartão já está vinculado
          }
        }
      }

      // Cartão não foi encontrado vinculado a nenhum usuário
      return false;
    } catch (e) {
      return false; // Em caso de erro, assume-se que o cartão não está vinculado
    }
  }

  // Função para vincular um cartão (manual ou NFC) ao usuário logado
  Future<String> linkCard(String cardCode) async {
    try {
      // Caso o cartão já tenha sido vinculado, não tenta vincular novamente
      if (await isCardLinked(cardCode)) {
        return 'Este código de cartão já está vinculado a outro usuário.';
      }

      // Vincula o cartão ao usuário atual
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);

      await userDocRef.collection('cartao').doc(cardCode).set({
        'Saldo': 0.0,
        'dataVinculo': DateTime.now(),
      });

      return 'Cartão cadastrado com sucesso!';
    } catch (e) {
      return 'Erro ao cadastrar cartão: $e';
    }
  }

  // Função para obter o nome do usuário
  Future<String> getUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      return userDoc.exists
          ? userDoc['nome'] ?? 'Nome não encontrado'
          : 'Nome não encontrado';
    } catch (e) {
      return 'Erro ao carregar nome';
    }
  }

  // Função para obter informações do cartão do usuário
  Future<Map<String, dynamic>> getUserCard() async {
    try {
      QuerySnapshot cartaoSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('cartao')
          .get();

      if (cartaoSnapshot.docs.isNotEmpty) {
        var card = cartaoSnapshot.docs.first;
        return {
          'hasCard': true,
          'nfcId': card.id,
          'saldo': card['Saldo'] ?? 0.0
        };
      } else {
        return {'hasCard': false};
      }
    } catch (e) {
      return {'hasCard': false};
    }
  }

  // Função para atualizar o saldo do cartão
  Future<void> updateCardBalance(String cardId, double amount) async {
    DocumentReference cardDocRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('cartao')
        .doc(cardId);

    await cardDocRef.update({
      'Saldo': FieldValue.increment(amount),
    });

    await cardDocRef.collection('historico').add({
      'data': Timestamp.now(),
      'tipo': 'Recarga',
      'valor': amount,
    });
  }
}
