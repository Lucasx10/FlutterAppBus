const express = require("express");
const axios = require("axios");
const bodyParser = require("body-parser");
const WebSocket = require("ws"); // Importa a biblioteca WebSocket
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000; // Porta do servidor

app.use(bodyParser.json());

const accessToken = process.env.TOKEN_DE_ACESSO; // Substitua pelo seu token real
const pagamentosMonitorados = {}; // Objeto para armazenar status dos pagamentos

// Inicia o servidor WebSocket
const wss = new WebSocket.Server({ noServer: true });

wss.on('connection', (ws) => {
  console.log('Novo cliente WebSocket conectado');
  
  // Envia uma mensagem de "conexão" inicial
  ws.send(JSON.stringify({ message: "Conexão WebSocket estabelecida." }));
});

// Configuração para o servidor HTTP aceitar conexões WebSocket
app.server = app.listen(PORT, () => {
  console.log(`🚀 Webhook rodando em http://localhost:${PORT}`);
});

app.server.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit('connection', ws, request);
  });
});

// Webhook que recebe a atualização do Mercado Pago
app.post('/webhook', async (req, res) => {
  const webhook = req.body;

  console.log("🔔 Webhook recebido:", webhook);

  if (!webhook.live_mode) {
      const paymentId = webhook.data.id;
      console.log(`📢 Pagamento ${paymentId} recebido em ambiente de teste`);

      if (pagamentosMonitorados[paymentId] && pagamentosMonitorados[paymentId] !== 'pending') {
          console.log(`✅ Pagamento ${paymentId} já foi atualizado para "${pagamentosMonitorados[paymentId]}", ignorando.`);
          return res.sendStatus(200);
      }

      try {
          // Busca os detalhes do pagamento na API do Mercado Pago
          const response = await axios.get(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
              headers: { Authorization: `Bearer ${accessToken}` }
          });

          const status = response.data.status;
          const paymentMethod = response.data.payment_type_id; // Obtém o método de pagamento
          console.log(`🔄 Pagamento ${paymentId} atualizado para: ${status} (Método: ${paymentMethod})`);

          // Atualiza o status no monitoramento
          pagamentosMonitorados[paymentId] = status;

          // Envia os dados via WebSocket
          wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
              client.send(JSON.stringify({ paymentId, status, paymentMethod }));
            }
          });

          if (status === 'approved' || status === 'rejected') {
              console.log(`✅ Pagamento ${paymentId} finalizado. Removendo do monitoramento.`);
              delete pagamentosMonitorados[paymentId];
          }

      } catch (error) {
          console.error(`❌ Erro ao buscar pagamento ${paymentId}:`, error.message);
      }
  } else {
      console.log(`⚠️ Webhook ignorado (live_mode: true)`);
  }

  res.sendStatus(200);
});

