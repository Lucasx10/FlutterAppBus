import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  /// Verifica se o dispositivo suporta e tem NFC habilitado
  Future<bool> checkNfcAvailability() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      print("Erro ao verificar disponibilidade do NFC: $e");
      return false;
    }
  }

  /// Converte uma lista de bytes para uma string hexadecimal
  String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  /// Lê uma tag NFC e retorna o ID da tag em formato hexadecimal
  Future<String> scanNfcTag() async {
    try {
      bool isAvailable = await checkNfcAvailability();
      if (!isAvailable) {
        throw 'O NFC não está disponível no dispositivo.';
      }

      Completer<String> completer = Completer();
      NfcManager.instance.startSession(
        alertMessage: "Aproxime a tag NFC para leitura.",
        onDiscovered: (NfcTag tag) async {
          try {
            // Extraia o ID da tag como uma lista de bytes
            List<int> cardIdBytes =
                tag.data['nfca']?['identifier']?.toList() ?? [];

            // Converta para hexadecimal
            String cardIdHex = bytesToHex(cardIdBytes);
            completer.complete(cardIdHex);
          } catch (e) {
            completer.completeError('Erro ao processar a tag NFC.');
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );

      return await completer.future;
    } catch (e) {
      throw 'Erro no NFC: $e';
    }
  }
}
