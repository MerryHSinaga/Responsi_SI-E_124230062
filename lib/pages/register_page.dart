import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _register() async {
    final prefs = await SharedPreferences.getInstance();

    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    String? raw = prefs.getString('users');
    Map<String, String> users = {};

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          users = Map<String, String>.from(decoded.map((k, v) => MapEntry(k.toString(), v.toString())));
        }
      } catch (_) {
        users = {};
      }
    }

    if (users.containsKey(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username sudah terdaftar!'), backgroundColor: Colors.red),
      );
      return;
    }

    users[user] = pass;

    await prefs.setString('users', jsonEncode(users));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrasi berhasil!'), backgroundColor: Colors.green),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text('Register'),
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
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text('Buat Akun Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                SizedBox(height: 25),
                TextField(
                  controller: _userCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Sudah punya akun? Login', style: TextStyle(color: Colors.orange.shade800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
