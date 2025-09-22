import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of all products, sorted by name
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('name') // Sort products by name alphabetically
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Get a stream of trending products
  Stream<List<Product>> getTrendingProducts() {
    final trendingStream = _db.collection('trending_products').limit(10).snapshots();

    return trendingStream.asyncMap((trendingSnapshot) async {
      final productIds = trendingSnapshot.docs
          .map((doc) => doc.data()['productId'] as String?)
          .where((id) => id != null)
          .toList();

      if (productIds.isEmpty) {
        return <Product>[];
      }

      final productsSnapshot = await _db
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      final products = productsSnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();

      products.sort((a, b) {
        final aIndex = productIds.indexOf(a.id);
        final bIndex = productIds.indexOf(b.id);
        return aIndex.compareTo(bIndex);
      });

      return products;
    });
  }
}
