class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final double price;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.price,
    required this.imageUrl,
  });

  Event.fromJson(Map<String, dynamic> json)
  : id = json['id'] as String,
    title = json['title'] as String,
    description = json['description'] as String,
    date = json['date'] as DateTime,
    price = json['price'] as double,
    imageUrl = json['imageUrl'] as String;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}