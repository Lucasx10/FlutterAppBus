import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/home/home.dart';
import 'package:login/pages/login/login_page.dart';
import 'package:login/pages/recarga/recarga_page.dart';
import 'package:login/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa o Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Acompanhar a mudança de estado de autenticação
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Tela de carregamento
        } else if (snapshot.hasData) {
          User user = snapshot.data!; // Usuário autenticado
          return FutureBuilder<Map<String, dynamic>>(
            future: FirebaseService(user.uid)
                .getUserCard(), // Obter dados do cartão
            builder: (context, cardSnapshot) {
              if (cardSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (cardSnapshot.hasData &&
                  cardSnapshot.data?['hasCard'] == true) {
                return MyHomePage(
                    user: user, nfcData: cardSnapshot.data!['cardId']);
              } else {
                return MyHomePage(user: user, nfcData: '');
              }
            },
          );
        } else {
          // Se o usuário não estiver logado, exibe a tela de login
          return LoginPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final User user; // Parâmetro para o usuário
  final String nfcData; // Parâmetro para os dados do cartão

  const MyHomePage({super.key, required this.user, required this.nfcData});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // A lista de páginas
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(HomePage(user: widget.user, title: "Home"));
    _pages.add(RecargaPage(
        nfcData: widget.nfcData)); // Passando nfcData para RecargaPage
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Quando a página de Recarga for selecionada, atualize os dados
      if (_selectedIndex == 1) {
        // Recria a página Recarga com dados atualizados
        _pages[1] = RecargaPage(nfcData: widget.nfcData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Recarga',
          ),
        ],
      ),
    );
  }
}
