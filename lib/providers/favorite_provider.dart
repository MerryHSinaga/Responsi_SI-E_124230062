import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../db/database_helper.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Restaurant> _favorites = [];
  bool _inited = false;

  List<Restaurant> get favorites => _favorites;

  Future<void> loadFavorites(String username) async {
    _favorites = await DatabaseHelper.instance.getFavorites(username);
    _inited = true;
    notifyListeners();
  }

  Future<void> addFavorite(Restaurant r, String username) async {
    await DatabaseHelper.instance.insertFavorite(r, username);
    _favorites.add(r);
    notifyListeners();
  }

  Future<void> removeFavorite(String id, String username) async {
    await DatabaseHelper.instance.removeFavorite(id, username);
    _favorites.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  bool isFavorite(String id, String username) {
    return _favorites.any((r) => r.id == id);
  }
}
