class Destination {
  final String id;
  final String name;
  final String location;
  final String description;
  final double price;
  final double rating;
  final List<String> imageUrls;
  final int favoritesCount;
  final int bookingsCount;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrls,
    this.favoritesCount = 0,
    this.bookingsCount = 0,
  });

  factory Destination.fromMap(String id, Map<String, dynamic> data) {
    return Destination(
      id: id,
      name: data['name'] as String,
      location: data['location'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      rating: (data['rating'] as num).toDouble(),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      favoritesCount: (data['favoritesCount'] as num?)?.toInt() ?? 0,
      bookingsCount: (data['bookingsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'price': price,
      'rating': rating,
      'imageUrls': imageUrls,
      'favoritesCount': favoritesCount,
      'bookingsCount': bookingsCount,
    };
  }
}