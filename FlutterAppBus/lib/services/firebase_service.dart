import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final String userId;

  FirebaseService(this.userId);

  // Verifica se o cartão já está vinculado a um usuário
  Future<bool> isCardLinked(String cardCode) async {
    try {
      // Busca o cartão na coleção "cartoes"
      DocumentSnapshot cardDoc = await FirebaseFirestore.instance
          .collection('cartoes')
          .doc(cardCode)
          .get();

      // Verifica se existe e se já possui um userId associado
      if (cardDoc.exists && cardDoc.data() != null) {
        return cardDoc['userId'] != null; // Retorna true se estiver vinculado
      }

      return false; // Não está vinculado
    } catch (e) {
      return false; // Em caso de erro, assume-se que o cartão não está vinculado
    }
  }

  // Vincula um cartão ao usuário atual
  Future<String> linkCard(String cardCode) async {
    try {
      // Verifica se o cartão já está vinculado
      if (await isCardLinked(cardCode)) {
        return 'Este cartão já está vinculado a outro usuário.';
      }

      // Atualiza o documento do usuário com o ID do cartão
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);

      // Adiciona ou atualiza o cartão na coleção "cartoes"
      DocumentReference cardDocRef =
          FirebaseFirestore.instance.collection('cartoes').doc(cardCode);

      // Atualiza os dados no Firestore
      await cardDocRef.set({
        'saldo': 0.0,
        'userId': userId,
        'dataVinculo': DateTime.now(),
      });

      await userDocRef.update({
        'cartaoID': cardCode,
      });

      return 'Cartão vinculado com sucesso!';
    } catch (e) {
      return 'Erro ao vincular cartão: $e';
    }
  }

  // Obtém informações do cartão do usuário
  Future<Map<String, dynamic>> getUserCard() async {
    try {
      // Obtém o documento do usuário
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      // Verifica se o usuário possui um cartaoID
      if (userDoc.exists && userDoc['cartaoID'] != null) {
        String cardId = userDoc['cartaoID'];

        // Busca o cartão na coleção "cartoes"
        DocumentSnapshot cardDoc = await FirebaseFirestore.instance
            .collection('cartoes')
            .doc(cardId)
            .get();

        if (cardDoc.exists) {
          return {
            'hasCard': true,
            'cardId': cardId,
            'saldo': cardDoc['saldo'] ?? 0.0,
          };
        }
      }

      return {'hasCard': false};
    } catch (e) {
      return {'hasCard': false};
    }
  }

  // Atualiza o saldo do cartão
  Future<void> updateCardBalance(
      String cardId, double amount, String paymentMethod) async {
    try {
      // Verifica se o cartão existe
      DocumentReference cardDocRef =
          FirebaseFirestore.instance.collection('cartoes').doc(cardId);
      DocumentSnapshot cardDoc = await cardDocRef.get();

      if (!cardDoc.exists) {
        throw Exception("Cartão não encontrado.");
      }

      // Atualiza o saldo do cartão
      await cardDocRef.update({
        'saldo': FieldValue.increment(amount),
      });

      if (paymentMethod == 'credit_card') {
        // Adiciona uma entrada ao histórico do cartão
        await cardDocRef.collection('historico').add({
          'data': Timestamp.now(),
          'tipo': 'Cartão de crédito', // Adicionando o método de pagamento
          'valor': amount,
        });
      } else {
        // Adiciona uma entrada ao histórico do cartão
        await cardDocRef.collection('historico').add({
          'data': Timestamp.now(),
          'tipo': 'PIX', // Adicionando o método de pagamento
          'valor': amount,
        });
      }
    } catch (e) {
      throw Exception('Erro ao atualizar o saldo: $e');
    }
  }

  // Obtém o nome do usuário
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

  Stream<double> getCardBalanceStream(String cardId) {
    return FirebaseFirestore.instance
        .collection('cartoes')
        .doc(cardId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()?['saldo'] ?? 0.0;
      } else {
        return 0.0;
      }
    });
  }

// Stream que retorna a localização do ônibus com base no número do ônibus fornecido
  Stream<List<Map<String, dynamic>>> getBusLocationByNumber(String busNumber) {
    try {
      return FirebaseFirestore.instance
          .collection('onibus')
          .where('numero', isEqualTo: busNumber) // Filtra pelo número do ônibus
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return {
            'id': doc.id,
            'location': data['location'],
          };
        }).toList();
      });
    } catch (e) {
      print('Erro ao obter a localização do ônibus: $e');
      return const Stream.empty(); // Retorna um Stream vazio em caso de erro
    }
  }

  // Stream que retorna a lista de números de ônibus
  Stream<List<String>> getBusNumbersStream() {
    try {
      return FirebaseFirestore.instance
          .collection('onibus')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          // Assume que o número do ônibus está no 'numero'
          return doc['numero']
              .toString(); // Retorna o número do ônibus como string
        }).toList();
      });
    } catch (e) {
      print('Erro ao obter os números dos ônibus: $e');
      return const Stream.empty(); // Retorna um Stream vazio em caso de erro
    }
  }
}
