import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/restaurant.dart';
import '../providers/favorite_provider.dart';

class DetailPage extends StatefulWidget {
  final String restaurantId;
  const DetailPage({super.key, required this.restaurantId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService api = ApiService();
  Restaurant? _r;
  bool _loading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _load();
    _loadUsername();
  }

  
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('currentUser') ?? ''; 

    if (_username.isNotEmpty) {
      final favProv = Provider.of<FavoriteProvider>(context, listen: false);
      await favProv.loadFavorites(_username);
    }

    setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _r = await api.fetchRestaurantDetail(widget.restaurantId);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favProv = Provider.of<FavoriteProvider>(context);

    final isFav = _r != null && _username.isNotEmpty
        ? favProv.isFavorite(_r!.id, _username)
        : false;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(_r?.name ?? 'Detail'),
        actions: [
          if (_r != null)
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: isFav ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                if (!isFav) {
                  await favProv.addFavorite(_r!, _username);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Ditambahkan ke favorit'),
                        backgroundColor: Colors.green),
                  );
                } else {
                  await favProv.removeFavorite(_r!.id, _username);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Dihapus dari favorit'),
                        backgroundColor: Colors.red),
                  );
                }
                setState(() {});
              },
            )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _r == null
              ? Center(child: Text('Tidak ada data'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_r!.pictureId.isNotEmpty)
                        Image.network(
                          'https://restaurant-api.dicoding.dev/images/large/${_r!.pictureId}',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _r!.name,
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 16, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        _r!.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.grey, size: 18),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${_r!.address}, ${_r!.city}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),
                            Text("Kategori:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: _r!.categories
                                  .map((c) => Chip(
                                        label: Text(c),
                                        backgroundColor:
                                            Colors.orange.shade100,
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 18),
                            Text("Deskripsi:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            Text(_r!.description),
                            SizedBox(height: 20),
                            Text("Menu Makanan:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (_r!.menus!['foods'] as List)
                                  .map((f) => Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(f['name']),
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 20),
                            Text("Menu Minuman:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (_r!.menus!['drinks'] as List)
                                  .map((d) => Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(d['name']),
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 24),
                            Text("Customer Reviews:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 10),
                            if (_r!.customerReviews != null &&
                                (_r!.customerReviews is List) &&
                                (_r!.customerReviews as List).isNotEmpty)
                              ...(_r!.customerReviews as List).map((cr) {
                                final name = cr['name'] ?? 'Anonymous';
                                final review = cr['review'] ?? '';
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Icon(Icons.person,
                                            color: Colors.white),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            SizedBox(height: 6),
                                            Text(review),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()
                            else
                              Text(
                                'Belum ada ulasan pelanggan.',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            SizedBox(height: 30),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
