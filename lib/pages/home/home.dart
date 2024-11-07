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

    setState(() {
      _userName = userName;
      _hasCard = userCard['hasCard'];
      _nfcData = userCard['nfcId'] ?? 'Scan a tag';
      _saldo = userCard['saldo'] ?? 0.0;
    });
  }

  Future<void> _scanNfcTag() async {
    try {
      String nfcId = await _nfcService.scanNfcTag();
      setState(() {
        _nfcData = nfcId;
      });
      await _firebaseService.linkNfcTag(nfcId);
      _initialize(); // Recarrega dados após vinculação
    } catch (e) {
      print(e);
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
            if (_hasCard) ...[
              CardWidget(nfcData: _nfcData, saldo: _saldo),
              ElevatedButton(
                onPressed: _rechargeCard,
                child: Text("Realizar Recarga"),
              ),
            ] else ...[
              NfcWidget(onScan: _scanNfcTag),
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
                      cardId: _nfcData, // Passa o ID do cartão
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
