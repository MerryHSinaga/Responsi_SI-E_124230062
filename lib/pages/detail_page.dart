
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/restaurant.dart';
import '../providers/favorite_provider.dart';

class DetailPage extends StatefulWidget {
  final String restaurantId;
  DetailPage({required this.restaurantId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService api = ApiService();
  Restaurant? _r;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    
    final favProv = Provider.of<FavoriteProvider>(context, listen: false);
    favProv.loadFavorites();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _r = await api.fetchRestaurantDetail(widget.restaurantId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favProv = Provider.of<FavoriteProvider>(context);
    final isFav = _r != null ? favProv.isFavorite(_r!.id) : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_r?.name ?? 'Detail'),
        actions: [
          if (_r != null)
            IconButton(
              icon: Icon(Icons.favorite, color: isFav ? Colors.red : const Color.fromARGB(255, 36, 100, 190)),
              onPressed: () async {
                if (!isFav) {
                  await favProv.addFavorite(_r!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ditambahkan ke favorit'), backgroundColor: Colors.green),
                  );
                } else {
                  await favProv.removeFavorite(_r!.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dihapus dari favorit'), backgroundColor: Colors.red),
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
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_r!.pictureId.isNotEmpty)
                        Image.network('https://restaurant-api.dicoding.dev/images/large/${_r!.pictureId}'),
                      SizedBox(height: 8),
                      Text(_r!.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4), ColoredBox(color:  Colors.orange, child: SizedBox(height: 2, width: 50)),
                      Text('${_r!.city} • ${_r!.address}'),
                      SizedBox(height: 8),
                      Text('Rating: ${_r!.rating.toStringAsFixed(1)}'),
                      SizedBox(height: 8),
                      if (_r!.categories.isNotEmpty) Text('Kategori: ${_r!.categories.join(', ')}'),
                      SizedBox(height: 8),
                      Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_r!.description),
                      SizedBox(height: 12),
                      if (_r!.menus != null) Text('Menu tersedia)'),
                      SizedBox(height: 12),
                      if (_r!.customerReviews != null) ...[
                        Text('Customer Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ..._r!.customerReviews!.map((cr) => ListTile(
                              title: Text(cr['name'] ?? ''),
                              subtitle: Text(cr['review'] ?? ''),
                              dense: true,
                            ))
                      ]
                    ],
                  ),
                ),
    );
  }
}
