import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final favProv = Provider.of<FavoriteProvider>(context);
    final items = favProv.favorites;
    return Scaffold(
      appBar: AppBar(title: Text('Favorit')),
      body: items.isEmpty
          ? Center(child: Text('Belum ada favorit'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final r = items[i];
                final thumb = r.pictureId.isNotEmpty ? 'https://restaurant-api.dicoding.dev/images/medium/${r.pictureId}' : '';
                return ListTile(
                  leading: thumb.isNotEmpty ? Image.network(thumb, width: 60, fit: BoxFit.cover) : null,
                  title: Text(r.name),
                  subtitle: Text('${r.city} • Rating ${r.rating.toStringAsFixed(1)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await favProv.removeFavorite(r.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dihapus dari favorit'), backgroundColor: Colors.red));
                    },
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(restaurantId: r.id))),
                );
              },
            ),
    );
  }
}