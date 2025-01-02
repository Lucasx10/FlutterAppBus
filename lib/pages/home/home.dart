import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/historico/historico.dart';
import 'package:login/services/firebase_service.dart';
import 'package:login/services/nfc_service.dart';
import 'package:login/widgets/user_widget.dart';
import 'package:login/widgets/card_widget.dart';
import 'dart:async';

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

  String _nfcData = '';
  String _userName = '';
  bool _hasCard = false;
  double _saldo = 0.0;
  bool _nfcSupported = false; // Flag para verificar se o NFC é suportado
  bool _isScanning = false;
  String _statusMessage = '';
  StreamSubscription<double>? _balanceSubscription;

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
      _nfcData = userCard['cardId'] ?? 'Scan a tag';
      _saldo = userCard['saldo'] ?? 0.0;
      _nfcSupported = isNfcAvailable; // Atualiza a variável de suporte ao NFC
    });

     // Inicia a escuta do saldo
    if (_hasCard) {
      _balanceSubscription?.cancel(); // Cancela qualquer stream anterior
      _balanceSubscription = _firebaseService
          .getCardBalanceStream(_nfcData)
          .listen((newSaldo) {
        setState(() {
          _saldo = newSaldo;
        });
      });
    }
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel(); // Cancela o stream ao descartar a tela
    super.dispose();
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
    String cardCode =
        _cardCodeController.text.replaceAll(' ', ''); // Remove espaços

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
    // Função para recarregar o saldo do cartão
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController rechargeController = TextEditingController();
        return AlertDialog(
          title: Text("Digite o valor da recarga"),
          content: TextField(
            controller: rechargeController,
            decoration: InputDecoration(hintText: "Valor da recarga"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                double rechargeAmount =
                    double.tryParse(rechargeController.text) ?? 0.0;
                if (rechargeAmount > 0) {
                  try {
                    // Atualiza o saldo do cartão no Firestore
                    await _firebaseService.updateCardBalance(
                        _nfcData, rechargeAmount);

                    // Atualiza o saldo local
                    setState(() {
                      _saldo += rechargeAmount;
                    });

                    // Recarrega os dados após a recarga
                    await _initialize();
                    Navigator.of(context).pop();

                    // Exibe a mensagem de sucesso com SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Recarga realizada com sucesso!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Handle any error that occurs during update
                    print("Erro ao atualizar saldo: $e");

                    // Exibe a mensagem de erro com SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Erro ao realizar recarga. Tente novamente."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Se o valor da recarga não for válido
                  print("Valor da recarga inválido");

                  // Exibe a mensagem de erro com SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Valor inválido. Insira um valor maior que 0."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Recarregar"),
            ),
          ],
        );
      },
    );
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
