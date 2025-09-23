import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../features/products/domain/product.dart';
import '../../features/cart/domain/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for all products (used in Catalog)
  Stream<List<Product>> getProductsStream() {
    // --- FIX: Added orderBy('name') to sort products alphabetically ---
    return _db.collection('products').orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // New stream for trending products
  Stream<List<Product>> getTrendingProductsStream() {
    return _db.collection('trending_products').snapshots().switchMap((snapshot) {
      final productIds = snapshot.docs.map((doc) => doc['productId'] as String).toList();

      if (productIds.isEmpty) {
        return Stream.value([]);
      }

      // Note: This combines streams but doesn't inherently guarantee order.
      // For trending products, the order is usually determined by the 'trending_products' collection itself.
      return CombineLatestStream.list(
        productIds.map((id) {
          return _db.collection('products').doc(id).snapshots().map((doc) {
            return doc.exists ? Product.fromFirestore(doc) : null;
          });
        }),
      ).map((products) => products.where((p) => p != null).cast<Product>().toList());
    });
  }

  // Method to get a single product by its ID
  Future<Product?> getProduct(String id) async {
    final snapshot = await _db.collection('products').doc(id).get();
    if (snapshot.exists) {
      return Product.fromFirestore(snapshot);
    } else {
      return null;
    }
  }

  // --- Cart Methods ---

  // Get the user's cart stream
  Stream<List<CartItem>> getCartStream(String uid) {
    return _db.collection('carts').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data()!;
      final items = (data['items'] as List).map((item) => CartItem.fromMap(item as Map<String, dynamic>)).toList();
      return items;
    });
  }

  // Update the user's cart
  Future<void> updateCart(String uid, List<CartItem> items) {
    final itemsMap = items.map((item) => item.toMap()).toList();
    return _db.collection('carts').doc(uid).set({
      'items': itemsMap,
    });
  }
}
