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
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': imageUrl,
      'category': category,
      'stock': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    double parsedPrice = 0.0;
    final priceValue = map['price'];

    if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else if (priceValue is String) {
      try {
        final cleanString = priceValue.replaceAll(RegExp(r'[^0-9]'), '');
        parsedPrice = double.tryParse(cleanString) ?? 0.0;
      } catch (_) {
        parsedPrice = 0.0;
      }
    }

    return Product(
      // This now correctly receives the 'id' from the fromFirestore factory.
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Nama Tidak Diketahui',
      description: map['description'] as String? ?? '',
      price: parsedPrice,
      imageUrl: map['image'] as String? ?? '',
      category: map['category'] as String? ?? 'Lain-lain',
      stock: (map['stock'] as num? ?? 0).toInt(),
    );
  }

  // --- THE DEFINITIVE FIX ---
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // CRITICAL FIX: Manually insert the document's ID into the data map.
    // This ensures that fromMap can access the ID and create a valid Product object.
    data['id'] = doc.id;
    // Now, delegate to fromMap, which will correctly assemble the object.
    return Product.fromMap(data);
  }
}
