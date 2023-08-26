import 'Stock.dart';

class Fund {
  final int? id; // Change here
  final String name;
  final String price;
  final List<Stock> stocks;

  Fund({
    this.id, // Change here
    required this.name,
    required this.price,
    required this.stocks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Change here
      'name': name,
      'price': price,
    };
  }

  factory Fund.fromMap(Map<String, dynamic> map) {
    return Fund(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stocks: [], // Initialize with an empty list
    );
  }
}
