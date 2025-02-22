# Configuração e Instalação

## Requisitos
- Flutter 3.24.4
- Node.js
- Firebase CLI
- Conta no Firebase
- Conta no Mercado Pago para obter credenciais da API
- Conta no Google Cloud para configuração da API do Google Maps

## Configuração do Ambiente

### 1. Clone o Repositório
```sh
  git clone https://github.com/Lucasx10/FlutterAppBus.git
  cd FlutterAppBus/FlutterAppBus
```

### 2. Instalação do Flutter
Certifique-se de ter o Flutter 3.24.4 instalado:
```sh
flutter --version
```
Caso não esteja instalado, siga as instruções no site oficial: [Flutter](https://docs.flutter.dev/get-started/install)

### 3. Configuração das Variáveis de Ambiente
Crie um arquivo `.env` na raiz do projeto e adicione:
```env
GOOGLE_MAPS_API_KEY=API_KEY_GOOGLE_MAPS
TOKEN_DE_ACESSO=TOKEN_MERCADO_PAGO
WEBSOCKET_URL=URL_DO_WEBSOCKET
```
Para o Webhook, crie um `.env` na pasta correspondente:
```env
TOKEN_DE_ACESSO=TOKEN_API_MERCADO_PAGO  
PORT=PORTA_DO_SERVIDOR
```

### 4. Configuração do Firebase
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione um app para Flutter (iOS e Android, conforme necessário)
3. Baixe o arquivo `google-services.json` (para Android) e coloque em `android/app/`
4. Baixe o arquivo `GoogleService-Info.plist` (para iOS) e coloque em `ios/Runner/`
5. Execute o comando:
   ```sh
   flutterfire configure
   ```
   Siga as instruções na tela para configurar automaticamente os arquivos do Firebase. (qualquer dúvida siga a documentação oficial: [Flutterfire](https://firebase.flutter.dev/docs/overview/))

### 5. Configuração da API do Google Maps
1. Crie uma conta no [Google Cloud Console](https://console.cloud.google.com/).
2. Habilite a **Maps JavaScript API** e **Geolocation API**.
3. Obtenha a chave da API e adicione ao `.env`:
```sh
  GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 6. Instalação das Dependências
```sh
flutter pub get
```

### 7. Configuração e Execução do Webhook
1. Acesse a pasta do backend:
```sh
  cd webhook
```
2. Instale as dependências:
```sh
  npm install
```
2. Execute o server e exponha o Webhook com o LocalTunnel 
```sh
node server.js
lt --port 3000 --subdomain cardappdbus
```

### 8. Execução do Projeto Flutter
```sh
flutter run
```