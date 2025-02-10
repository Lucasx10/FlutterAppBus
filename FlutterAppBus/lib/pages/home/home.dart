import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/home/cadastro_nfc_page.dart';
import 'package:login/pages/home/cadastro_sem_nfc_page.dart';
import 'package:login/pages/login/login_page.dart';
import 'package:login/services/firebase_service.dart';
import 'package:login/services/nfc_service.dart';
import 'package:login/widgets/historico_widget.dart';
import 'package:login/widgets/card_widget.dart';
import 'dart:async';
import '../../shared/constants/custom_colors.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.user,
    required this.title,
  });

  final String title;
  final User user;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late FirebaseService _firebaseService;
  late NfcService _nfcService;

  int paginaAtual = 0;
  String _nfcData = '';
  String _userName = '';
  bool _hasCard = false;
  double _saldo = 0.0;
  bool _isScanning = false;
  String _statusMessage = '';
  StreamSubscription<double>? _balanceSubscription;
  bool _isLoading = true;

  CustomColors customColors = CustomColors();

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();

    _firebaseService = FirebaseService(widget.user.uid);
    _nfcService = NfcService();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    String userName = await _firebaseService.getUserName();
    Map<String, dynamic> userCard = await _firebaseService.getUserCard();

    setState(() {
      _userName = userName;
      _hasCard = userCard['hasCard'];
      _nfcData = userCard['cardId'] ?? 'Scan a tag';
      _saldo = (userCard['saldo'] ?? 0.0).toDouble();
      _isLoading = false;
    });

    if (_hasCard) {
      _balanceSubscription?.cancel();
      _balanceSubscription =
          _firebaseService.getCardBalanceStream(_nfcData).listen((newSaldo) {
        setState(() {
          _saldo = newSaldo.toDouble();
        });
      });
    }
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _navigateToCardRegistration() async {
    bool isNfcAvailable = await _nfcService.checkNfcAvailability();

    if (isNfcAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NfcCardRegistrationPage(
            nfcService: _nfcService,
            firebaseService: _firebaseService,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManualCardRegistrationPage(
            firebaseService: _firebaseService,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedSaldo = NumberFormat("#,##0.00", "pt_BR").format(_saldo);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _initialize,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_isLoading) CircularProgressIndicator(),
                if (!_isLoading) ...[
                  if (_hasCard) ...[
                    CardWidget(cardName: _userName, cardNumber: _nfcData),
                    Text("Saldo Disponível: ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("R\$ $formattedSaldo",
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    SizedBox(height: 20),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: 250,
                            height: 150,
                            child: Center(
                              child: Icon(Icons.add_card_outlined,
                                  color: Colors.blue, size: 40),
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 16),
                            child: Text(
                              "Clique no botão abaixo para adicionar um cartão",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade700),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _navigateToCardRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  customColors.getActivePrimaryButtonColor(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                            ),
                            child: Text(
                              "+  Cadastrar cartão",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 40),
                          if (_isScanning) CircularProgressIndicator(),
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
                        ],
                      ),
                    ),
                  ],
                  Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Histórico de Recargas:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(icon: Icon(Icons.search), onPressed: () {}),
                      ],
                    ),
                  ),
                  TransactionHistoryWidget(cardId: _nfcData),
                ],
              ],
            ),
          ),
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
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
