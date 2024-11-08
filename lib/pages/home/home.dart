import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/historico/historico.dart';
import 'package:login/pages/profile/profile.dart';
import 'package:login/services/firebase_service.dart';
import 'package:login/services/nfc_service.dart';
import 'package:login/shared/constants/custom_colors.dart';
import 'package:login/widgets/my_app_bar.dart';
import 'package:login/widgets/user_widget.dart';
import 'package:login/widgets/card_widget.dart';
import 'package:login/widgets/nfc_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
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

  int _currentIndex = 0; // Índice da página selecionada

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
                  } catch (e) {
                    // Handle any error that occurs during update
                    print("Erro ao atualizar saldo: $e");
                  }
                } else {
                  // Se o valor da recarga não for válido
                  print("Valor da recarga inválido");
                }
              },
              child: Text("Recarregar"),
            ),
          ],
        );
      },
    );
  }

  // Alterna as telas com base no índice selecionado
  Widget _getSelectedPage() {
    switch (_currentIndex) {
      case 0:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserWidget(userName: _userName),
              if (_hasCard) ...[
                CardWidget(nfcData: _nfcData, saldo: _saldo),
                ElevatedButton(
                  onPressed: _rechargeCard,
                  child: const Text("Realizar Recarga"),
                ),
              ] else ...[
                NfcWidget(onScan: _scanNfcTag),
              ],
            ],
          ),
        );
      case 1:
        return TransactionHistoryPage(
          userId: widget.user.uid,
          cardId: _nfcData,
        );
      case 2:
        return Profile(
          name: _userName,
          email: widget.user.email ?? 'Email não disponível',
        );
      default:
        return const Center(child: Text("Página não encontrada"));
    }
  }

  // Método para atualizar o título com base no índice selecionado
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Início';
      case 1:
        return 'Histórico';
      case 2:
        return 'Perfil';
      default:
        return 'Página não encontrada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors().gradienteMainColor,
      appBar: myAppBar(
        title: _getAppBarTitle(), // Passa o título dinamicamente
        implyLeading: false,
        context: context,
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
