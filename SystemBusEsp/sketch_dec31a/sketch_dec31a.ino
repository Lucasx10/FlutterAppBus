#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <SPI.h>
#include <MFRC522.h>
#include <addons/TokenHelper.h>
#include <TinyGPS++.h>

// Configuração do RFID
#define SS_PIN 5
#define RST_PIN 2
MFRC522 mfrc522(SS_PIN, RST_PIN);   // Instância do MFRC522

// Defina o RX e TX para o GPS
#define RXD2 16
#define TXD2 17
#define GPS_BAUD 9600

// O objeto TinyGPS++
TinyGPSPlus gps;

// Crie uma instância da classe HardwareSerial para o Serial 2
HardwareSerial gpsSerial(2);

// Configuração do Wi-Fi
#define WIFI_SSID ""        // Substitua pelo nome da sua rede Wi-Fi
#define WIFI_PASSWORD ""  // Substitua pela senha da sua rede Wi-Fi

// Defina a chave da API do Firebase
#define API_KEY ""  // Substitua pela sua chave de API

// Defina o ID do projeto do Firebase
#define FIREBASE_PROJECT_ID ""  // Substitua pelo seu ID de projeto do Firebase

// Defina as credenciais do usuário para autenticação no Firebase
#define USER_EMAIL ""  // Substitua pelo seu e-mail
#define USER_PASSWORD ""          // Substitua pela sua senha

// Defina o objeto FirebaseData
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(9600);

  // Iniciar o Serial 2 com os pinos RX e TX definidos e uma taxa de 9600 bauds
  gpsSerial.begin(GPS_BAUD, SERIAL_8N1, RXD2, TXD2);
  Serial.println("Serial 2 started at 9600 baud rate");

  //inicia o RFID
  SPI.begin();                    // Inicializa SPI bus
  mfrc522.PCD_Init();             // Inicializa MFRC522

  Serial.println("Conectando ao Wi-Fi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Conectando...");
  }
  Serial.println("Conectado ao Wi-Fi!");

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  // Definir a chave da API
  config.api_key = API_KEY;

  // Definir as credenciais do usuário
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Atribuir a função de callback para o status do token
  config.token_status_callback = tokenStatusCallback; // Função de callback do token

  // Inicializar o Firebase
  Firebase.begin(&config, &auth);

  // Configurar buffer de BSSL para SSL
  fbdo.setBSSLBufferSize(4096, 1024);
  fbdo.setResponseSize(2048);

  Serial.println("Aproxime o cartão do leitor...");
}

void loop() {
  // Chama as funções separadas para GPS e RFID
  lerGPS();
  lerRFID();
}

// Função para ler os dados de GPS e enviar ao Firebase
void lerGPS() {
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }

  if (gps.location.isUpdated()) {
    float latitude = gps.location.lat();
    float longitude = gps.location.lng();

    Serial.print("LAT: ");
    Serial.println(latitude, 6);
    Serial.print("LONG: ");
    Serial.println(longitude, 6);

    // Criar o objeto FirebaseJson com os dados de localização
    FirebaseJson locationJson;
    locationJson.set("fields/location/lat", latitude);
    locationJson.set("fields/location/lng", longitude);

    // Caminho para o documento do ônibus no Firestore
    String busPath = "onibus/CVUUhPHDtSZrv3WjQWL6";

    // Atualiza os dados de localização no Firebase
    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", busPath.c_str(), locationJson.raw(), "location")) {
      Serial.println("Localização atualizada no Firebase!");
    } else {
      Serial.println("Erro ao atualizar localização: " + fbdo.errorReason());
    }

    delay(5000);  // Envia os dados a cada 5 segundos
  }
}

// Função para ler o cartão RFID e atualizar os dados no Firebase
void lerRFID() {
  if (!mfrc522.PICC_IsNewCardPresent()) {
    return;  // Nenhum cartão encontrado, sai da função
  }

  if (!mfrc522.PICC_ReadCardSerial()) {
    return;  // Se não conseguir ler o cartão, sai da função
  }

  // Converte UID para string
  String cardUID = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) {
      cardUID += "0";  // Adiciona um zero à esquerda se necessário
    }
    cardUID += String(mfrc522.uid.uidByte[i], HEX);
  }
  Serial.println("Cartão detectado: " + cardUID);

  // Caminho para acessar o cartão na coleção /cartoes
  String cardPath = "cartoes/" + cardUID;

  // Obter dados dos cartões
  if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", cardPath.c_str(), "")) {
    Serial.println("Dados do cartão encontrados:");
    Serial.println(fbdo.payload());

    // Extrai o saldo do JSON
    FirebaseJson payloadJson;
    payloadJson.setJsonData(fbdo.payload());
    
    // Objeto FirebaseJsonData para capturar o saldo
    FirebaseJsonData saldoData;

    // Acessa o saldo do cartão
    if (payloadJson.get(saldoData, "fields/saldo/integerValue")) {
      // Converte o saldo para float
      float saldo = saldoData.to<float>();
      Serial.println("Saldo encontrado para o cartão: R$" + String(saldo, 2));

      // Verificar se o saldo é suficiente
      if (saldo >= 5.50) {
        saldo -= 5.50; // Deduzir a tarifa

        // Atualizar o saldo no Firebase
        FirebaseJson updateJson;
        updateJson.set("fields/saldo/doubleValue", saldo);

        if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", cardPath.c_str(), updateJson.raw(), "saldo")) {
          Serial.println("Novo saldo para o cartão: R$" + String(saldo, 2));
        } else {
          Serial.println("Erro ao atualizar saldo: " + fbdo.errorReason());
        }
      } else {
        Serial.println("Saldo insuficiente para o cartão.");
      }
    } 
    // Se não for 'integerValue', tenta 'doubleValue'
    else if (payloadJson.get(saldoData, "fields/saldo/doubleValue")) {
      float saldo = saldoData.to<float>();
      Serial.println("Saldo encontrado para o cartão: R$" + String(saldo, 2));

      // Verificar se o saldo é suficiente
      if (saldo >= 5.50) {
        saldo -= 5.50; // Deduzir a tarifa

        // Atualizar o saldo no Firebase
        FirebaseJson updateJson;
        updateJson.set("fields/saldo/doubleValue", saldo);

        if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", cardPath.c_str(), updateJson.raw(), "saldo")) {
          Serial.println("Novo saldo para o cartão: R$" + String(saldo, 2));
        } else {
          Serial.println("Erro ao atualizar saldo.");
        }
      } else {
        Serial.println("Saldo insuficiente para o cartão.");
      }
    } 
    // Caso o saldo não esteja disponível
    else {
      Serial.println("Saldo não encontrado.");
    }
  } else {
    Serial.println("Erro ao obter dados do Firestore: " + fbdo.errorReason());
  }

  mfrc522.PICC_HaltA();  // Para a comunicação com o cartão RFID
  delay(1000);  // Pausa para evitar leituras repetidas
}
