import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/features/products/domain/product.dart';

class Promotion {
  final String id;
  final String productId;
  final double discountPrice;
  final DateTime startDate;
  final DateTime endDate;

  Promotion({
    required this.id,
    required this.productId,
    required this.discountPrice,
    required this.startDate,
    required this.endDate,
  });

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      productId: data['productId'] ?? '',
      discountPrice: (data['discountPrice'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }
}

class PromoProduct {
  final Product product;
  final Promotion promotion;

  PromoProduct({
    required this.product,
    required this.promotion,
  });
}
