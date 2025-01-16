import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/nfc_service.dart';
import '../../shared/constants/custom_colors.dart';

class NfcCardRegistrationPage extends StatefulWidget {
  final NfcService nfcService;
  final FirebaseService firebaseService;
  final customColors = CustomColors();

  NfcCardRegistrationPage(
      {required this.nfcService, required this.firebaseService});

  @override
  _NfcCardRegistrationPageState createState() =>
      _NfcCardRegistrationPageState();
}

class _NfcCardRegistrationPageState extends State<NfcCardRegistrationPage> {
  bool _isScanning =
      false; // Controla a visibilidade do CircularProgressIndicator

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context); // Navega para a página anterior
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Cadastrar Cartão NFC",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: false, // Título alinhado à direita
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc,
                size: 100,
                color: widget.customColors.getActivePrimaryButtonColor()),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
              child: Text(
                "Aproxime e mantenha seu cartão encostado na parte de trás do celular",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800),
              ),
            ),
            if (_isScanning)
              CircularProgressIndicator(), // Exibe o indicador de progresso durante o escaneamento
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isScanning = true; // Mostra o indicador de progresso
                });

                // Simula o escaneamento NFC
                String nfcId = await widget.nfcService.scanNfcTag();

                bool isCardLinked =
                    await widget.firebaseService.isCardLinked(nfcId);

                if (!isCardLinked) {
                  await widget.firebaseService.linkCard(nfcId);

                  // Exibe a Snackbar com a mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cartão vinculado com sucesso!"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Espera 2 segundos antes de voltar
                  await Future.delayed(Duration(seconds: 2));
                  Navigator.pop(context);
                } else {
                  // Exibe a Snackbar com a mensagem de erro
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Este cartão já está vinculado a outro usuário."),
                      backgroundColor: Colors.red,
                    ),
                  );

                  // Espera 2 segundos
                  await Future.delayed(Duration(seconds: 2));
                }

                setState(() {
                  _isScanning =
                      false; // Oculta o indicador de progresso após a operação
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.customColors.getActivePrimaryButtonColor(),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text("Escanear Cartão",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
