import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/firebase_options.dart';
import 'package:login/pages/home/home.dart';
import 'package:login/pages/recarga/recarga_page.dart';
import 'package:login/pages/login/login_page.dart';

import 'pages/gps/gps_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Bus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RoteadorTela(),
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return BottomNavBar(user: snapshot.data!);
        } else {
          return LoginPage();
        }
      },
    );
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.authStateChanges().first;
  }
}

class BottomNavBar extends StatefulWidget {
  final User user;

  const BottomNavBar({super.key, required this.user});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

// Modificação no BottomNavBar
class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(
        user: widget.user,
        title: 'Início',
      ),
      GpsPage(),
      RecargaPage(user: widget.user),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: _onItemTapped,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.departure_board,
              size: 30,
            ),
            label: 'GPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.credit_card,
              size: 30,
            ),
            label: 'Recarga',
          ),
        ],
      ),
    );
  }
}
