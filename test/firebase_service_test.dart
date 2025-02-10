import 'package:flutter_test/flutter_test.dart';
import 'package:login/services/firebase_service.dart';

final Map<String, dynamic> fakeFirestoreData = {
  'cartoes': {
    'cardCode1': {'userId': 'userId1', 'saldo': 10.0},
    'cardCode2': {'userId': null, 'saldo': 0.0},
    'cardCode3': {'userId': null, 'saldo': 50.0},
  },
  'usuarios': {
    'userId': {'cartaoID': 'cardCode1', 'nome': 'João'},
  },
  'onibus': {
    'bus1': {
      'numero': '123',
      'location': {'latitude': 1.0, 'longitude': 2.0}
    },
    'bus2': {
      'numero': '456',
      'location': {'latitude': 3.0, 'longitude': 4.0}
    },
  }
};

class FakeFirebaseService extends FirebaseService {
  FakeFirebaseService(String userId) : super(userId);

  @override
  Future<Map<String, dynamic>> getUserCard() async {
    final user = fakeFirestoreData['usuarios']?[userId] ?? {};
    final cardId = user['cartaoID'];
    if (cardId != null) {
      final cardData = fakeFirestoreData['cartoes']?[cardId] ?? {};
      return {
        'hasCard': true,
        'cardId': cardId,
        'saldo': cardData['saldo'] ?? 0.0
      };
    }
    return {'hasCard': false};
  }

  @override
  Future<String> linkCard(String cardCode) async {
    final card = fakeFirestoreData['cartoes']?[cardCode];

    if (card != null && card['userId'] == null) {
      final Map<String, Object?> updatedCard = Map<String, Object?>.from(card);
      updatedCard['userId'] = userId;

      fakeFirestoreData['cartoes']?[cardCode] = updatedCard;
      return 'Cartão vinculado com sucesso!';
    }
    return 'Erro ao vincular cartão';
  }

  @override
  Future<void> updateCardBalance(
      String cardId, double value, String method) async {
    if (fakeFirestoreData['cartoes']?[cardId] != null) {
      fakeFirestoreData['cartoes']?[cardId]['saldo'] += value;
    }
  }

  @override
  Future<String> getUserName() async {
    return fakeFirestoreData['usuarios'][userId]?['nome'] ??
        'Erro ao carregar nome';
  }

  @override
  Stream<List<Map<String, dynamic>>> getBusLocationByNumber(String busNumber) {
    return Stream.value([
      {
        'id': 'bus1',
        'location': {'latitude': 1.0, 'longitude': 2.0}
      },
      {
        'id': 'bus2',
        'location': {'latitude': 3.0, 'longitude': 4.0}
      },
    ]);
  }

  @override
  Stream<List<String>> getBusNumbersStream() {
    return Stream.value(['123', '456']);
  }

  @override
  Future<bool> isCardLinked(String cardCode) async {
    final card = fakeFirestoreData['cartoes']?[cardCode];
    return card != null && card['userId'] != null;
  }
}

void main() {
  group('Testando o FirebaseService', () {
    late FirebaseService firebaseService;

    setUp(() {
      firebaseService = FakeFirebaseService('userId');
    });

    test('Testa se o cartão já está vinculado', () async {
      final cardData = await firebaseService.getUserCard();
      expect(cardData['hasCard'], true);
    });

    test('Testa o vínculo de cartão', () async {
      final String result = await firebaseService.linkCard('cardCode3');
      expect(result, 'Cartão vinculado com sucesso!');
    });

    test('Testa a atualização do saldo do cartão', () async {
      await firebaseService.updateCardBalance('cardCode1', 20.0, 'credit_card');
      final cardData = await firebaseService.getUserCard();
      expect(cardData['saldo'], 30.0);
    });

    test('Testa o nome do usuário', () async {
      final result = await firebaseService.getUserName();
      expect(result, 'João');
    });

    test('Testa a verificação de cartão vinculado', () async {
      final result = await firebaseService.isCardLinked('cardCode1');
      expect(result, true);
    });

    test('Testa a verificação de cartão não vinculado', () async {
      final result = await firebaseService.isCardLinked('cardCode2');
      expect(result, false);
    });

    test('Testa o stream de localização dos ônibus', () async {
      final busStream = firebaseService.getBusLocationByNumber('123');
      final busLocations = await busStream.first;
      expect(busLocations.length, 2);
      expect(busLocations[0]['id'], 'bus1');
      expect(busLocations[1]['id'], 'bus2');
    });

    test('Testa o stream de números de ônibus', () async {
      final busNumbersStream = firebaseService.getBusNumbersStream();
      final busNumbers = await busNumbersStream.first;
      expect(busNumbers.length, 2);
      expect(busNumbers[0], '123');
      expect(busNumbers[1], '456');
    });
  });
}
