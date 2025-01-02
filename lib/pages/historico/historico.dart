import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String userId;
  final String cardId;

  const TransactionHistoryPage({
    Key? key,
    required this.userId,
    required this.cardId,
  }) : super(key: key);

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Stream<QuerySnapshot> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _transactionsStream = FirebaseFirestore.instance
        .collection('cartoes')
        .doc(widget.cardId) // Usando o ID do cartão
        .collection('historico')
        .orderBy('data',
            descending: true) // Ordena pela data, mais recente primeiro
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico de Transações"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _transactionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico.'));
          }

          final transactions = snapshot.data?.docs ?? [];

          if (transactions.isEmpty) {
            return Center(child: Text("Nenhuma transação encontrada."));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final data = (transaction['data'] as Timestamp).toDate();
              final tipo = transaction['tipo'];
              final valor = transaction['valor'];

              return ListTile(
                title: Text("Tipo: $tipo"),
                subtitle: Text(
                    "Data: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(data)} \nValor: R\$ ${valor.toStringAsFixed(2)}"),
              );
            },
          );
        },
      ),
    );
  }
}
