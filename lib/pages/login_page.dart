import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();

    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username dan Password wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? raw = prefs.getString('users');
    bool ok = false;

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);

        if (decoded is Map) {
          final users = Map<String, String>.from(
            decoded.map((k, v) => MapEntry(k.toString(), v.toString())),
          );

          if (users.containsKey(user) && users[user] == pass) {
            ok = true;
          }
        }
      } catch (_) {
        ok = false;
      }
    }

    if (!ok) {
      final savedUser = prefs.getString('username');
      final savedPass = prefs.getString('password');
      if (savedUser != null && savedPass != null && savedUser == user && savedPass == pass) {
        ok = true;
      }
    }

 
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username atau Password salah!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    await prefs.setString('currentUser', user);
    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu, size: 80, color: Colors.orange.shade700),
                SizedBox(height: 10),
                Text(
                  'Restaurant App',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800),
                ),
                SizedBox(height: 25),

                // Username
                TextField(
                  controller: _userCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // Password
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    'Belum punya akun? Daftar',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
