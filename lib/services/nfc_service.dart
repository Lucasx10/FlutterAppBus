import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  Future<String> scanNfcTag() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      Completer<String> completer = Completer();
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        try {
          String nfcId = tag.data['ndef']?['identifier']?.toString() ??
              'ID NFC não encontrado';
          completer.complete(nfcId);
          NfcManager.instance.stopSession();
        } catch (e) {
          completer.completeError('Erro ao ler tag NFC');
          NfcManager.instance.stopSession(errorMessage: 'Erro ao ler tag NFC.');
        }
      });
      return completer.future;
    } else {
      throw 'NFC não disponível';
    }
  }
}
