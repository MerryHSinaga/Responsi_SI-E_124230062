
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../db/database_helper.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Restaurant> _favorites = [];
  bool _inited = false;

  List<Restaurant> get favorites => _favorites;

  Future<void> loadFavorites() async {
    if (!_inited) {
      _favorites = await DatabaseHelper.instance.getFavorites();
      _inited = true;
      notifyListeners();
    }
  }

  Future<void> addFavorite(Restaurant r) async {
    await DatabaseHelper.instance.insertFavorite(r);
    _favorites.add(r);
    notifyListeners();
  }

  Future<void> removeFavorite(String id) async {
    await DatabaseHelper.instance.removeFavorite(id);
    _favorites.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((r) => r.id == id);
  }
}
