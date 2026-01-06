class Favorite {
  final String id;
  final String userId;
  final String destinationId;

  Favorite({
    required this.id,
    required this.userId,
    required this.destinationId,
  });

  factory Favorite.fromMap(String id, Map<String, dynamic> data) {
    return Favorite(
      id: id,
      userId: data['userId'],
      destinationId: data['destinationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'destinationId': destinationId,
    };
  }
}