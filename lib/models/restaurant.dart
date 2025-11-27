class Restaurant {
  final String id;
  final String name;
  final String city;
  final String address;
  final double rating;
  final String pictureId;
  final String description;
  final List<String> categories;
  final Map<String, dynamic>? menus;
  final List<dynamic>? customerReviews;

  Restaurant({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.rating,
    required this.pictureId,
    required this.description,
    required this.categories,
    this.menus,
    this.customerReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    double ratingDouble;
    final r = json['rating'];
    if (r is int) {
      ratingDouble = r.toDouble();
    } else if (r is double) {
      ratingDouble = r;
    } else if (r is String) {
      ratingDouble = double.tryParse(r) ?? 0.0;
    } else {
      ratingDouble = 0.0;
    }

    List<String> cats = [];
    if (json['categories'] != null) {
      try {
        cats = List.from(json['categories']).map((c) =>
            c is Map ? (c['name'] ?? '').toString() : c.toString()).toList();
      } catch (_) {
        cats = [];
      }
    }

    return Restaurant(
      id: json['id'] ?? json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      rating: ratingDouble,
      pictureId: json['pictureId'] ?? '',
      description: json['description'] ?? '',
      categories: cats,
      menus: json['menus'],
      customerReviews: json['customerReviews'] != null
          ? List.from(json['customerReviews'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'city': city,
        'address': address,
        'rating': rating,
        'pictureId': pictureId,
        'description': description,
        'categories': categories.join(','),
      };

  factory Restaurant.fromMap(Map<String, dynamic> m) {
    return Restaurant(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
      city: m['city']?.toString() ?? '',
      address: m['address']?.toString() ?? '',
      rating: (m['rating'] is num)
          ? (m['rating'] as num).toDouble()
          : double.tryParse(m['rating']?.toString() ?? '0') ?? 0.0,
      pictureId: m['pictureId']?.toString() ?? '',
      description: m['description']?.toString() ?? '',
      categories: (m['categories']?.toString() ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      menus: null,
      customerReviews: null,
    );
  }
}
