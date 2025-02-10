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
      "payment_methods": {
        "excluded_payment_types": [
          {"id": "ticket"},
        ],
      },
      "notification_url":
          "https://cardappdbus.loca.lt/webhook?source_news=webhooks",
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
}
