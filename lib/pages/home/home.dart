import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _nfcSupported = false; // Flag para verificar se o NFC é suportado
  bool _isScanning = false;
  String _statusMessage = '';
  StreamSubscription<double>? _balanceSubscription;
  bool _isLoading = true; // Adicionando estado de loading

  final TextEditingController _cardCodeController = TextEditingController();
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
      _isLoading = true; // Ativa o indicador de progresso
    });

    String userName = await _firebaseService.getUserName();
    Map<String, dynamic> userCard = await _firebaseService.getUserCard();

    bool isNfcAvailable = await _nfcService.checkNfcAvailability();

    setState(() {
      _userName = userName;
      _hasCard = userCard['hasCard'];
      _nfcData = userCard['cardId'] ?? 'Scan a tag';
      _saldo = (userCard['saldo'] ?? 0.0).toDouble();
      _nfcSupported = isNfcAvailable; // Atualiza a variável de suporte ao NFC
      _isLoading = false; // Desativa o indicador de progresso
    });

    // Inicia a escuta do saldo
    if (_hasCard) {
      _balanceSubscription?.cancel(); // Cancela qualquer stream anterior
      _balanceSubscription =
          _firebaseService.getCardBalanceStream(_nfcData).listen((newSaldo) {
        setState(() {
          _saldo =
              newSaldo.toDouble(); // Garantir que o saldo seja sempre um double
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
        // Exibe SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cartão vinculado com sucesso!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    String formattedSaldo = NumberFormat("#,##0.00", "pt_BR").format(_saldo);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:
              const EdgeInsets.only(top: 16.0), // Adiciona espaçamento no topo
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _initialize, // Função chamada ao arrastar a tela
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Garante que o scroll sempre esteja disponível
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_isLoading) // Exibe o CircularProgressIndicator enquanto carrega
                  CircularProgressIndicator(),
                if (!_isLoading) ...[
                  if (_hasCard) ...[
                    // Exibe o card e histórico quando o usuário tem cartão
                    CardWidget(cardName: _userName, cardNumber: _nfcData),

                    Text(
                      "Saldo Disponível: ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Cor para o "Saldo Disponível"
                      ),
                    ),
                    SizedBox(height: 10), // Espaço entre as linhas
                    Text(
                      "R\$ $formattedSaldo", // Valor do saldo
                      style: TextStyle(
                        fontSize: 36, // Maior fonte para o valor
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Cor azul para o valor
                      ),
                    ),
                    SizedBox(height: 20),
                  ] else ...[
                    // Exibe o botão de cadastro e o card vazio quando o usuário não tem cartão
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Column(
                        children: [
                          // Card vazio transparente em cima do botão
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: 250,
                            height: 150,
                            child: Center(
                              child: Icon(
                                Icons.add_card_outlined,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Mensagem centralizada
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
                            onPressed: _scanNfcTag,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  customColors.getActivePrimaryButtonColor(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                            ),
                            child: Text(
                              "+  Cadastrar cartão com NFC",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 40),
                          if (_isScanning)
                            CircularProgressIndicator(), // Exibe o indicador de progresso
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    customColors.getActivePrimaryButtonColor(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                              ),
                              child: Text("Vincular Cartão Manualmente"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Linha horizontal
                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // Título "Histórico de Recargas" e ícone de lupa
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Histórico de Recargas:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            // Ação de pesquisa (adicione a lógica conforme necessário)
                          },
                        ),
                      ],
                    ),
                  ),

                  // Widget de histórico
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
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(), // Substitua por sua página de login
                  ),
                  (Route<dynamic> route) =>
                      false, // Remove todas as rotas anteriores
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
