class Event {
  final String? id;
  final String title;
  final String image;
  final DateTime date;
  final String description;
  final double price;
  bool isFavorite;

  Event({
    this.id,
    required this.title,
    required this.image,
    required this.date,
    required this.description,
    required this.price,
    this.isFavorite = false,
  });

  Event.fromJson(Map<String, dynamic> json)
  : id = json['id'] as String,
    title = json['title'] as String,
    image = json['image'] as String,
    date =  DateTime.parse(json['date'] as String),
    description = json['description'] as String,
    price = (json['price'] as num).toDouble(),
    isFavorite = false;

  Map<String, dynamic> toJson() {
    if (id == null ) {
      return {
      'title': title,
      'image': image,
      'date': date.toIso8601String(),
      'description': description,
      'price': price,
    };
    } else {
      return {
        'id': id,
        'title': title,
        'image': image,
        'date': date.toIso8601String(),
        'description': description,
        'price': price,
      };     
    }
  }
}