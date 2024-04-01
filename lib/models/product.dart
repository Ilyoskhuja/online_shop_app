class Product {
  final int id;
  final String title;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String? ?? 'No description provided',
    imageUrl: json['thumbnailUrl'] as String? ?? 'No image URL provided',
  );
}


Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
  };
}
}
