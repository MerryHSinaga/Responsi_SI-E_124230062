import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/restaurant.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService api = ApiService();
  List<Restaurant> _list = [];
  bool _loading = true;
  String _username = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _loadUsername();
  }


  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _load({String? q}) async {
    setState(() => _loading = true);
    try {
      if (q != null && q.isNotEmpty) {
        _list = await api.search(q);
      } else {
        _list = await api.fetchRestaurants();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _item(Restaurant r) {
    final thumb = r.pictureId.isNotEmpty
        ? 'https://restaurant-api.dicoding.dev/images/medium/${r.pictureId}'
        : '';

    return ListTile(
      leading: thumb.isNotEmpty
          ? Image.network(thumb, width: 60, fit: BoxFit.cover)
          : null,
      title: Text(r.name),
      subtitle: Text('${r.city} • Rating ${r.rating.toStringAsFixed(1)}'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(restaurantId: r.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $_username'),
        actions: [
          // Favorite 
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),

          // Logout
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              await prefs.remove('password');

            
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari restoran...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _load(q: _searchCtrl.text.trim()),
                  child: Text('Cari'),
                ),
              ],
            ),
          ),

          // List restoran
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _load(),
                    child: ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (_, i) => _item(_list[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}