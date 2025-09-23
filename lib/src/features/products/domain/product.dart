import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;
  final String description;
  final Timestamp? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  static double _parsePrice(dynamic price) {
    if (price is String) {
      final cleanedPrice = price.replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(cleanedPrice) ?? 0.0;
    } else if (price is num) {
      return price.toDouble();
    }
    return 0.0;
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String imageUrl = data['image'] as String? ?? '';
    if (imageUrl.isEmpty) {
      imageUrl = 'https://picsum.photos/seed/${doc.id}/200/300';
    }

    int stock = (data['stock'] as num?)?.toInt() ?? (data['stok'] as num?)?.toInt() ?? 0;

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? 'No Name',
      price: _parsePrice(data['price']),
      imageUrl: imageUrl,
      stock: stock,
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updated_at'] as String?,
    );
  }
}
