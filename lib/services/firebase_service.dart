import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final String userId;

  FirebaseService(this.userId);

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

  //Função para vincular a tag do cartão NFC ao usuário logado (caso ele não tenha nenhum cartão vinculado)
  Future<void> linkNfcTag(String nfcId) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('usuarios').doc(userId);

    await userDocRef.collection('cartao').doc(nfcId).set({
      'Saldo': 0.0,
      'dataVinculo': DateTime.now(),
    });
  }
}
