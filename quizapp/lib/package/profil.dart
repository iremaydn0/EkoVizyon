import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(profile());
}

class profile extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Çıkış yapma fonksiyonu
  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Çıkış yapıldı."),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Çıkış yaparken bir hata oluştu."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Kullanıcı adı kısmı
            Center(
              child: user != null
                  ? Column(
                children: [
                  Text(
                    'Hoşgeldin ${user.displayName ?? "Kullanıcı"}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
                  : Text("Kullanıcı girmedi"),
            ),
            SizedBox(height: 20),

            // Şifre değiştirme butonu
            _buildButton(
              context,
              label: 'Şifre Değiştir',
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 10),

            // Çıkış yapma butonu
            _buildButton(
              context,
              label: 'Çıkış Yap',
              onPressed: () {
                // Çıkış yapma işlevini burada çağırıyoruz
                _signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Genel buton yapısı
  Widget _buildButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff2d6a4f),
        minimumSize: Size(double.infinity, 50), // Butonun tam genişlikte olmasını sağlar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Şifre değiştirme sayfası
class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Şifre değiştirme fonksiyonu
  Future<void> _changePassword(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kullanıcı giriş yapmamış."),
      ));
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Yeni şifreler eşleşmiyor."),
      ));
      return;
    }

    try {
      // Mevcut şifreyi doğrulama
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      // Şu anki şifreyi kullanarak oturum açma
      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi güncelleme
      await user.updatePassword(_newPasswordController.text);
      await user.reload();
      user = _auth.currentUser;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Şifreniz başarıyla değiştirildi!"),
      ));
      Navigator.pop(context); // İşlemden sonra önceki sayfaya dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Şifre değiştirilemedi. Lütfen tekrar deneyin."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifre Değiştir'),
        backgroundColor: Color(0xff2d6a4f),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Güncel Şifre'),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Mevcut şifrenizi girin',
              ),
            ),
            SizedBox(height: 10),
            Text('Yeni Şifre'),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Yeni şifrenizi girin',
              ),
            ),
            SizedBox(height: 10),
            Text('Yeni Şifreyi Onaylayın'),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Yeni şifrenizi onaylayın',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _changePassword(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2d6a4f),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Şifreyi Değiştir',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


