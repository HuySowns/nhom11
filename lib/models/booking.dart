class Booking {
  final String id;
  final String userId;
  final String destinationId;
  final DateTime date;
  final int numPeople;

  Booking({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.date,
    required this.numPeople,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      userId: data['userId'] as String,
      destinationId: data['destinationId'] as String,
      date: DateTime.parse(data['date'] as String),
      numPeople: (data['numPeople'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'destinationId': destinationId,
      'date': date.toIso8601String(),
      'numPeople': numPeople,
    };
  }
}