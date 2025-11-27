import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedUser = prefs.getString('username');
    String? savedPass = prefs.getString('password');

    String user = _userCtrl.text.trim();
    String pass = _passCtrl.text.trim();

  
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    
    if (savedUser == null || savedPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Akun belum terdaftar! Silakan Register dulu.'), backgroundColor: Colors.red),
      );
      return;
    }

    // Cek username dan password
    if (user == savedUser && pass == savedPass) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username atau Password salah!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),
            SizedBox(height: 10),
            Text('Restaurant App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            // Username
            TextField(
              controller: _userCtrl,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            SizedBox(height: 15),

            // Password
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            SizedBox(height: 25),

            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
                backgroundColor: Colors.orange,
              ),
              child: Text('Login'),
            ),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Belum punya akun? Daftar'),
            )
          ],
        ),
      ),
    );
  }
}