class Stock {
  final int? id; // Change here
  final int fundId;
  final String name;
  final double percentage;

  Stock({
    this.id, // Change here
    required this.fundId,
    required this.name,
    required this.percentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Change here
      'fundId': fundId,
      'name': name,
      'percentage': percentage,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      fundId: map['fundId'],
      name: map['name'],
      percentage: map['percentage'],
    );
  }
}