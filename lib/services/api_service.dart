import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class ApiService {
  static const base = 'https://restaurant-api.dicoding.dev';

  Future<List<Restaurant>> fetchRestaurants() async {
    final url = Uri.parse('$base/list');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      final List list = body['restaurants'] ?? [];
      return list.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<Restaurant> fetchRestaurantDetail(String id) async {
    final url = Uri.parse('$base/detail/$id');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      final data = body['restaurant'];
      return Restaurant.fromJson(data);
    } else {
      throw Exception('Failed to load detail');
    }
  }

  // Buat Search 
  Future<List<Restaurant>> search(String q) async {
    final url = Uri.parse('$base/search?q=$q');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      final List list = body['restaurants'] ?? [];
      return list.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception('Search failed');
    }
  }
}