import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/historico/historico.dart';
import 'package:login/services/firebase_service.dart';
import 'package:login/services/nfc_service.dart';
import 'package:login/widgets/user_widget.dart';
import 'package:login/widgets/card_widget.dart';
import 'package:login/widgets/nfc_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user, required this.title});

  final String title;
  final User user;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late FirebaseService _firebaseService;
  late NfcService _nfcService;

  String _nfcData = 'Scan a tag';
  String _userName = '';
  bool _hasCard = false;
  double _saldo = 0.0;
  bool _nfcSupported = false; // Flag para verificar se o NFC é suportado

  bool _isScanning = false;
  String _statusMessage = '';

  TextEditingController _cardCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(widget.user.uid);
    _nfcService = NfcService();
    _initialize();
  }

  Future<void> _initialize() async {
    String userName = await _firebaseService.getUserName();
    Map<String, dynamic> userCard = await _firebaseService.getUserCard();

    bool isNfcAvailable = await _nfcService.checkNfcAvailability();

    setState(() {
      _userName = userName;
      _hasCard = userCard['hasCard'];
      _nfcData = userCard['nfcId'] ?? 'Scan a tag';
      _saldo = userCard['saldo'] ?? 0.0;
      _nfcSupported = isNfcAvailable; // Atualiza a variável de suporte ao NFC
    });
  }

  Future<void> _scanNfcTag() async {
    setState(() {
      _isScanning = true;
      _statusMessage = "Aproxime o cartão na parte de trás do celular.";
    });

    try {
      if (!_nfcSupported) {
        setState(() {
          _statusMessage =
              "Seu celular não tem suporte ao NFC. Digite o código do cartão.";
          _isScanning = false;
        });
        return;
      }

      // Obtém o ID da tag NFC
      String nfcId = await _nfcService.scanNfcTag();

      // Verifica se o cartão já está vinculado a outro usuário
      bool isCardLinked = await _firebaseService.isCardLinked(nfcId);
      if (isCardLinked) {
        setState(() {
          _statusMessage = "Este cartão NFC já está vinculado a outro usuário.";
          _isScanning = false;
        });
        return; // Impede que o cartão seja vinculado se já estiver em uso
      }

      // Se o cartão não estiver vinculado, tenta vincular
      setState(() {
        _nfcData = nfcId;
        _statusMessage = "Cartão vinculado com sucesso! ID: $nfcId";
        _isScanning = false;
      });

      // Vincula o NFC ao usuário no Firebase
      await _firebaseService.linkCard(nfcId);
      _initialize(); // Atualiza os dados do usuário

    } catch (e) {
      setState(() {
        _statusMessage = "Erro ao vincular tag NFC: $e";
        _isScanning = false;
      });
    }
  }

  Future<void> _handleCardInput() async {
    String cardCode = _cardCodeController.text;

    // Verifica se o cartão já está vinculado antes de tentar cadastrar
    bool isCardLinked = await _firebaseService.isCardLinked(cardCode);
    if (isCardLinked) {
      setState(() {
        _statusMessage = 'Este cartão já está vinculado a outro usuário.';
      });
      return;
    }

    // Se o cartão não estiver vinculado, então vincula
    String result = await _firebaseService.linkCard(cardCode);
    setState(() {
      _statusMessage = result;
    });

    if (result == 'Cartão cadastrado com sucesso!') {
      _initialize();
    }
  }


  Future<void> _rechargeCard() async {
    // Código para recarga, podendo ser extraído para um método específico
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserWidget(userName: _userName),
            if (_isScanning) ...[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ] else if (_hasCard) ...[
              CardWidget(nfcData: _nfcData, saldo: _saldo),
              ElevatedButton(
                onPressed: _rechargeCard,
                child: Text("Realizar Recarga"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _scanNfcTag,
                child: Text("Vincular Cartão com NFC"),
              ),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              SizedBox(height: 16),
              if (!_nfcSupported) ...[
                TextField(
                  controller: _cardCodeController,
                  decoration: InputDecoration(
                    labelText: 'Código do Cartão',
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleCardInput,
                  child: Text("Vincular Cartão Manualmente"),
                ),
              ],
            ],
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName.isEmpty ? "Usuário" : _userName),
              accountEmail: Text(widget.user.email!),
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: const Text('Deslogar'),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: const Text("Ver Histórico de Transações"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryPage(
                      userId: widget.user.uid,
                      cardId: _nfcData,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
