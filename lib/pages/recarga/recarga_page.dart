import 'package:flutter/material.dart';
import 'package:login/services/firebase_service.dart';
import 'package:login/shared/constants/custom_colors.dart';

class RecargaPage extends StatefulWidget {
  final String nfcData;

  const RecargaPage({super.key, required this.nfcData});

  @override
  _RecargaPageState createState() => _RecargaPageState();
}

class _RecargaPageState extends State<RecargaPage> {
  late FirebaseService _firebaseService;
  TextEditingController _rechargeController = TextEditingController();
  bool _isLoading = false;
  double _selectedAmount = 0.0;

  int? _selectedButtonIndex;

  // Instanciar a classe CustomColors
  final customColors = CustomColors();

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService(widget.nfcData);
  }

  Future<void> _rechargeCard() async {
    FocusScope.of(context).unfocus();

    double rechargeAmount =
        double.tryParse(_rechargeController.text) ?? _selectedAmount;

    if (rechargeAmount > 0) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseService.updateCardBalance(
            widget.nfcData, rechargeAmount);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Recarga realizada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint("Erro ao realizar recarga: $e");
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Valor inválido. Insira um valor maior que 0."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recarga do Cartão")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Qual o valor da recarga?",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                : null, // Remover o fundo quando não selecionado
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
                                : null, // Remover o fundo quando não selecionado
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
                                : null, // Remover o fundo quando não selecionado
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
                    SizedBox(height: 10),
                    TextField(
                      controller: _rechargeController,
                      decoration: InputDecoration(
                        labelText: "Valor",
                        prefixText: "R\$ ",
                        prefixStyle: TextStyle(
                          color: customColors
                              .getActivePrimaryButtonColor(), // Cor azul
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign:
                          TextAlign.center, // Centraliza o texto no campo
                      style: TextStyle(
                        color: customColors
                            .getActivePrimaryButtonColor(), // Cor azul
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _rechargeCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: customColors.getActivePrimaryButtonColor(),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Recarregar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
