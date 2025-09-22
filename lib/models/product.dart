import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.description,
  });

  static double _parsePrice(dynamic price) {
    // (Price parsing logic remains the same)
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

    String imageUrl = data['imageUrl'] ?? '';
    if (imageUrl.isEmpty) {
      imageUrl = 'https://firebasestorage.googleapis.com/v0/b/react-native-crud-63233.appspot.com/o/products%2Fplaceholder.png?alt=media&token=895a5258-57c2-422e-a3b0-3f0f7811a2f5';
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      price: _parsePrice(data['price']),
      imageUrl: imageUrl,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }
}
