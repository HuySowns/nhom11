class Destination {
  final String id;
  final String name;
  final String location;
  final String description;
  final double price;
  final double rating;
  final List<String> imageUrls;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrls,
  });

  factory Destination.fromMap(String id, Map<String, dynamic> data) {
    return Destination(
      id: id,
      name: data['name'],
      location: data['location'],
      description: data['description'],
      price: data['price'].toDouble(),
      rating: data['rating'].toDouble(),
      imageUrls: List<String>.from(data['imageUrls']),
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
    };
  }
}