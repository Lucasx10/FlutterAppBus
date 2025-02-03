import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:login/services/firebase_service.dart';
import 'package:login/shared/constants/custom_colors.dart';
import 'package:login/shared/validators/recarga_validator.dart';
import 'package:login/services/mercadopago_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RecargaPage extends StatefulWidget {
  final User user;

  const RecargaPage({super.key, required this.user});

  @override
  _RecargaPageState createState() => _RecargaPageState();
}

class _RecargaPageState extends State<RecargaPage> {
  late WebSocketChannel channel;
  late FirebaseService _firebaseService;
  TextEditingController _rechargeController = TextEditingController();
  bool _isLoading = false;
  double _selectedAmount = 0.0;
  int? _selectedButtonIndex;
  String _nfcData = '';
  final customColors = CustomColors();
  final RechargeValidator _rechargeValidator = RechargeValidator();
  final MercadoPagoService _mercadoPagoService = MercadoPagoService();

  @override
  void initState() {
    super.initState();

    // Conecta ao WebSocket
    channel = WebSocketChannel.connect(
      Uri.parse(dotenv.env['WEBSOCKET_URL'] ??
          'ws://localhost:3000'), // URL do seu servidor WebSocket
    );

    // Escuta as mensagens do servidor WebSocket
    channel.stream.listen((message) async {
      final decodedMessage = jsonDecode(message) as Map<String, dynamic>;
      print("Mensagem recebida: $decodedMessage");
      String paymentMethod = decodedMessage['paymentMethod'];

      // Se o pagamento foi aprovado, atualiza o saldo no Firebase
      if (decodedMessage["status"] == "approved") {
        final rechargeAmount = _selectedAmount > 0.0
            ? _selectedAmount
            : double.tryParse(_rechargeController.text) ?? 0.0;

        if (rechargeAmount > 0.0) {
          await _firebaseService.updateCardBalance(
              _nfcData, rechargeAmount, paymentMethod);
          showSnackBar("Pagamento aprovado! Recarga realizada.", Colors.green);
        } else {
          showSnackBar("Erro ao processar recarga.", Colors.red);
        }
      } else {
        print("Pagamento não aprovado: $decodedMessage");
      }
    });

    // Inicializa o FirebaseService
    _firebaseService = FirebaseService(widget.user.uid);
    _rechargeController.clear();
    _selectedAmount = 0.0;
    _selectedButtonIndex = null;
    _fetchUserCard(); // Busca o cartão vinculado ao usuário
  }

// Exibe um SnackBar com o status do pagamento e a cor apropriada
  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor, // Define a cor do SnackBar
      ),
    );
  }

  Future<void> _fetchUserCard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> userCard = await _firebaseService.getUserCard();
      if (userCard['hasCard']) {
        setState(() {
          _nfcData = userCard['cardId'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Nenhum cartão vinculado ao usuário."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao buscar NFC Data."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rechargeCard() async {
    FocusScope.of(context).unfocus();

    double rechargeAmount =
        double.tryParse(_rechargeController.text) ?? _selectedAmount;

    // Validação do valor de recarga
    String? validationMessage =
        _rechargeValidator.validate(_rechargeController.text);
    if (validationMessage != null) {
      // Exibe um erro se o valor for inválido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (rechargeAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, insira um valor válido para a recarga."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o MercadoPagoService para criar a preferência de pagamento
      final checkoutUrl = await _mercadoPagoService.createPreference(
        context,
        rechargeAmount,
        widget.user.email!,
        widget.user.displayName ?? '',
      );
    } catch (e) {
      debugPrint("Erro ao carregar checkout Mercado Pago: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao realizar recarga. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Fecha a conexão WebSocket quando a página for destruída
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:
              const EdgeInsets.only(top: 16.0), // Adiciona espaçamento no topo
          child: Text(
            "Recarga do cartão",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else ...[
              SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Qual o valor da recarga?",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedAmount = 5.0;
                                _rechargeController.text = '5';
                                _selectedButtonIndex = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedButtonIndex == 0
                                  ? customColors.getActivePrimaryButtonColor()
                                  : null,
                              side: BorderSide(color: Colors.grey, width: 1),
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              foregroundColor: _selectedButtonIndex == 0
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                            child: Text("R\$ 5"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedAmount = 20.0;
                                _rechargeController.text = '20';
                                _selectedButtonIndex = 1;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedButtonIndex == 1
                                  ? customColors.getActivePrimaryButtonColor()
                                  : null,
                              side: BorderSide(color: Colors.grey, width: 1),
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              foregroundColor: _selectedButtonIndex == 1
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                            child: Text("R\$ 20"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedAmount = 50.0;
                                _rechargeController.text = '50';
                                _selectedButtonIndex = 2;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedButtonIndex == 2
                                  ? customColors.getActivePrimaryButtonColor()
                                  : null,
                              side: BorderSide(color: Colors.grey, width: 1),
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              foregroundColor: _selectedButtonIndex == 2
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                            child: Text("R\$ 50"),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      IntrinsicHeight(
                        child: TextField(
                          controller: _rechargeController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              border: OutlineInputBorder(),
                              prefixText:
                                  'R\$ ', // Adiciona o prefixo visual "R$"
                              prefixStyle: TextStyle(
                                color:
                                    customColors.getActivePrimaryButtonColor(),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              suffixIcon: Icon(
                                Icons.edit_outlined,
                                size: 30,
                                color:
                                    customColors.getActivePrimaryButtonColor(),
                              )),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: customColors.getActivePrimaryButtonColor(),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            // Remove o prefixo 'R$ ' antes de processar o valor no código
                            if (value.startsWith('R\$')) {
                              _rechargeController.text =
                                  value.replaceFirst('R\$ ', '');
                              _rechargeController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _rechargeController.text.length),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _isLoading ? null : _rechargeCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customColors.getActivePrimaryButtonColor(),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Recarregar",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
