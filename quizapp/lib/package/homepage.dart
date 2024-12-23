import 'package:flutter/material.dart';
import 'profil.dart';
import 'home.dart';
import 'quiz_page.dart';
import 'score.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Debug yazısını kaldırır
    home: HomePage(), // Ana sayfa HomePage olarak ayarlandı
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Seçili menü indeksi

  // Her menü için gösterilecek sayfalar
  final List<Widget> _pages = [

    CombinedQuizPage(),
    LeaderboardPage(),
    profile(),
    //profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EkoVizyon"),
        backgroundColor: Color(0xff52b69a),
      ),
      body: _pages[_currentIndex], // Seçili sayfayı göster
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Aktif sekme
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Menü tıklanınca sayfa değiştir
          });
        },
        type: BottomNavigationBarType.fixed, // Menüleri sabit tutar
        selectedItemColor: Color(0xff2d6a4f), // Seçili menü rengi
        unselectedItemColor: Colors.grey, // Seçili olmayan menü rengi
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Rozetler",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
