import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryWidget extends StatelessWidget {
  final String cardId;

  const TransactionHistoryWidget({Key? key, required this.cardId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verifica se cardId está vazio
    if (cardId.isEmpty) {
      return Center(
        child: Text(
          "Nenhuma transação encontrada.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final Stream<QuerySnapshot> transactionsStream = FirebaseFirestore.instance
        .collection('cartoes')
        .doc(cardId)
        .collection('historico')
        .orderBy('data', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar histórico.'));
        }

        final transactions = snapshot.data?.docs ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Text(
              "Nenhuma transação encontrada.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: transactions.map((transaction) {
            final data = (transaction['data'] as Timestamp).toDate();
            final valor = transaction['valor'];
            final tipo = transaction['tipo'];
            String formattedValor =
                NumberFormat("#,##0.00", "pt_BR").format(valor);
            return Card(
              color: Color(0xFFE2E2E2),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data: ${DateFormat('dd/MM/yyyy').format(data)}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Valor: R\$ $formattedValor",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Método de pagamento: $tipo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
