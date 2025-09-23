import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/cart/domain/cart_item.dart';
import '../../features/products/domain/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<CartItem>> getCartStream(String uid) {
    return _db.collection('carts').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return [];
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList();
      return items;
    });
  }

  Future<void> updateCart(String uid, List<CartItem> items) {
    final itemsMap = items.map((item) => item.toMap()).toList();
    return _db.collection('carts').doc(uid).set({'items': itemsMap});
  }
}
