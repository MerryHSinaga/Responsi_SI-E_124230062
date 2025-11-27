import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../models/restaurant.dart';
import 'detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  Future<void> _loadUserAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('currentUser') ?? '';

    if (_username.isNotEmpty) {
      await Provider.of<FavoriteProvider>(context, listen: false)
          .loadFavorites(_username);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favProv = Provider.of<FavoriteProvider>(context);
    final List<Restaurant> items = favProv.favorites;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Favorite Saya"),
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                "Belum ada favorit.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final r = items[i];

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
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                    
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://restaurant-api.dicoding.dev/images/medium/${r.pictureId}',
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),

                   
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.orange, size: 16),
                                SizedBox(width: 4),
                                Text(r.rating.toString()),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //Hapus
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await favProv.removeFavorite(r.id, _username);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dihapus dari favorit'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),

                      //Detail
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(restaurantId: r.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
