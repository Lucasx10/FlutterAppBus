import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String nfcData;
  final double saldo;

  const CardWidget({super.key, required this.nfcData, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Cartão: $nfcData"),
        Text("Saldo: R\$ ${saldo.toStringAsFixed(2)}"),
      ],
    );
  }
}
