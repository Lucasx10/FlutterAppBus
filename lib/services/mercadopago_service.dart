import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class MercadoPagoService {
  final String? accessToken =
      dotenv.env['TOKEN_DE_ACESSO']; // Substitua pelo seu token de acesso

  // Função para criar a preferência de pagamento
  Future<String> createPreference(BuildContext context, double rechargeAmount,
      String userEmail, String userName) async {
    const url = 'https://api.mercadopago.com/checkout/preferences';

    final Map<String, dynamic> body = {
      "items": [
        {
          "id": "AppRecarga",
          "title": "Recarga do cartão",
          "description": "Recarga do saldo do cartão",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": rechargeAmount
        }
      ],
      "payer": {
        "name": userName,
        "surname": "",
        "email": userEmail,
      },
      "back_urls": {
        "success": "https://test.com/success",
        "pending": "https://test.com/pending",
        "failure": "https://test.com/failure"
      },
      "notification_url":
          "https://webhook.site/ccdc9578-0bed-44d4-9f2b-5ceb691850b4",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final checkoutUrl = jsonResponse['init_point'];

        if (checkoutUrl != null) {
          _openCheckout(context, checkoutUrl);
          return checkoutUrl;
        } else {
          throw Exception("URL de checkout não encontrada.");
        }
      } else {
        throw Exception('Erro ao criar preferência: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar ao Mercado Pago.')),
      );
      rethrow;
    }
  }

  // Função para verificar o status do pagamento com base no ID
  Future<String> checkPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mercadopago.com/v1/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['status']; // Retorna o status do pagamento
      } else {
        throw Exception(
            'Erro ao verificar o status do pagamento: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
      throw Exception('Erro ao verificar o status do pagamento');
    }
  }

  // Abre a página de checkout no navegador
  void _openCheckout(BuildContext context, String checkoutUrl) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse(checkoutUrl),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.primaryColor,
          ),
        ),
      );
    } catch (e) {
      print('Erro ao abrir o checkout: $e');
    }
  }

  // Função para processar o webhook recebido
  Future<void> processWebhook(Map<String, dynamic> webhookData) async {
    try {
      final paymentId = webhookData['data']['id'];
      if (paymentId != null) {
        final status = await checkPaymentStatus(paymentId);
        print('Status do pagamento $paymentId: $status');
        // Aqui você pode fazer ações adicionais com o status do pagamento
      } else {
        print('ID de pagamento não encontrado no webhook');
      }
    } catch (e) {
      print('Erro ao processar webhook: $e');
    }
  }
}
