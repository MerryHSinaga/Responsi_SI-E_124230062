import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favorite_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/favorite_page.dart';
import 'pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

 
  final bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(initialRoute: loggedIn ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoriteProvider(),
      child: MaterialApp(
        title: 'Restaurant App',
        theme: ThemeData(primarySwatch: Colors.teal),
        initialRoute: initialRoute,
        routes: {
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
          '/home': (_) => HomePage(),
          '/favorites': (_) => FavoritePage(),
        },
      ),
    );
  }
}
