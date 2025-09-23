import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      // NOTE: Storing as 'image' to match the definitive field name from Firestore.
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': imageUrl, // Write back using the correct field name.
      'category': category,
      'stock': stock,
    };
  }

  // --- DEFINITIVE FIX for data loading issues ---
  factory Product.fromMap(Map<String, dynamic> map) {
    double parsedPrice = 0.0;
    final priceValue = map['price'];

    if (priceValue is num) {
      // Case 1: The price is already a number (the ideal case).
      parsedPrice = priceValue.toDouble();
    } else if (priceValue is String) {
      // Case 2: The price is a formatted string (e.g., "Rp 40.000").
      try {
        // Clean the string by removing all non-digit characters.
        final cleanString = priceValue.replaceAll(RegExp(r'[^0-9]'), '');
        parsedPrice = double.tryParse(cleanString) ?? 0.0;
      } catch (_) {
        // If parsing fails for any reason, default to 0.0.
        parsedPrice = 0.0;
      }
    }

    return Product(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Nama Tidak Diketahui',
      description: map['description'] as String? ?? '',
      price: parsedPrice, // Use the safely parsed price.
      // --- FIX: Using the correct 'image' field from Firestore data ---
      imageUrl: map['image'] as String? ?? '', // The internal variable is still imageUrl for consistency.
      category: map['category'] as String? ?? 'Lain-lain',
      stock: (map['stock'] as num? ?? 0).toInt(),
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // All data conversion is now centralized in the robust fromMap factory.
    return Product.fromMap(data);
  }
}
