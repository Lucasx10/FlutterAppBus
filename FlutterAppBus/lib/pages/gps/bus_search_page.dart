import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/gps/gps_page.dart';
import '../../services/firebase_service.dart'; // Adicione essa importação para acessar Firestore

class BusSearchPage extends StatefulWidget {
  const BusSearchPage({super.key});

  @override
  _BusSearchPageState createState() => _BusSearchPageState();
}

class _BusSearchPageState extends State<BusSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _busNumbers = [];
  List<String> _filteredBusNumbers = [];
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    // Inicializando o FirebaseService aqui
    _initializeFirebaseService(); // Garantir que o FirebaseService seja inicializado

    // Carrega os números dos ônibus do Firestore
    _loadBusNumbers();
  }

  Future<void> _initializeFirebaseService() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firebaseService = FirebaseService(user.uid);
    } else {
      print('Nenhum usuário logado.');
    }
  }

  // Função para carregar os números de ônibus a partir do Firestore
  void _loadBusNumbers() {
    _firebaseService.getBusNumbersStream().listen((busNumbers) {
      setState(() {
        _busNumbers = busNumbers;
        _filteredBusNumbers = _busNumbers;
      });
    });
  }

  void _filterBusNumbers() {
    setState(() {
      _filteredBusNumbers = _busNumbers
          .where((busNumber) => busNumber.contains(_searchController.text))
          .toList();
    });
  }

  void _onBusSelected(String busNumber) {
    // Navega para a página de GPS com a localização do ônibus
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GpsPage(busNumber: busNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Pesquisar Ônibus",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Número do ônibus',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _filterBusNumbers(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredBusNumbers.length,
                itemBuilder: (context, index) {
                  String busNumber = _filteredBusNumbers[index];
                  return Card(
                    color: Colors.blue,
                    margin: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 14),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bus,
                            size: 50.0,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  busNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8.0),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    'Última atualização: 12:30 PM', // Substituir por dados reais de atualização
                                    style: const TextStyle(
                                        fontSize: 12.0, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _onBusSelected(busNumber),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
