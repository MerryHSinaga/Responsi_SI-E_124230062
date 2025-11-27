import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/restaurant.dart';
import '../providers/favorite_provider.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService api = ApiService();
  List<Restaurant> _list = [];
  bool _loading = true;
  String _username = '';
  final _searchCtrl = TextEditingController();

  String _selectedCategory = "Semua";

  final List<String> _categories = [
    "Semua",
    "Italia",
    "Modern",
    "Sunda",
    "Jawa",
    "Bali"
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _load();
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
    final thumb = (r.pictureId.isNotEmpty)
        ? 'https://restaurant-api.dicoding.dev/images/medium/${r.pictureId}'
        : 'https://via.placeholder.com/65';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            thumb,
            width: 65,
            height: 65,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                'https://via.placeholder.com/65',
                width: 65,
                height: 65,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        title: Text(
          r.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(r.city),
              ],
            ),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text(r.rating.toString()),
              ],
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(restaurantId: r.id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Halo, $_username!"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              await prefs.remove('currentUser');

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
          SizedBox(height: 8),

        
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final bool active = _selectedCategory == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: active,
                      selectedColor: Colors.orange,
                      onSelected: (v) {
                        setState(() {
                          _selectedCategory = cat;
                          _searchCtrl.clear();
                        });

                        if (cat == "Semua") {
                          _load();
                        } else {
                          _load(q: cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Kolom search
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari restoran...',
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () => _load(q: _searchCtrl.text.trim()),
                  child: Text("Cari"),
                )
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
                      padding: EdgeInsets.only(top: 4),
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
