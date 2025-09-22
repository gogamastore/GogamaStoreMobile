import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // PRODUCTS
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getTrendingProducts() {
    final trendingStream = _db.collection('trending_products').limit(10).snapshots();
    return trendingStream.asyncMap((snapshot) => _fetchProductsFromIds(snapshot));
  }

  Future<List<Product>> _fetchProductsFromIds(QuerySnapshot trendingSnapshot) async {
    final productIds = trendingSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((data) => data.containsKey('productId'))
        .map((data) => data['productId'] as String)
        .toList();

    if (productIds.isEmpty) return [];

    final productsSnapshot = await _db
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .get();
    
    final products = productsSnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    
    // Preserve original order from trending_products
    products.sort((a, b) => productIds.indexOf(a.id).compareTo(productIds.indexOf(b.id)));

    return products;
  }

  // CART
  Stream<List<CartItem>> getCartStream(String userId) {
    final cartCollection = _db.collection('users').doc(userId).collection('cart');
    
    return cartCollection.snapshots().asyncMap((snapshot) async {
      final cartDocs = snapshot.docs;
      if (cartDocs.isEmpty) return [];
      
      // Extract product IDs and quantities from cart
      final productQuantities = { for (var doc in cartDocs) doc.id: doc.data()['quantity'] as int };
      final productIds = cartDocs.map((doc) => doc.id).toList();

      // Fetch product details
      final productsSnapshot = await _db.collection('products').where(FieldPath.documentId, whereIn: productIds).get();
      final products = productsSnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      
      // Create CartItem objects
      return products.map((product) {
        return CartItem(
          product: product,
          quantity: productQuantities[product.id] ?? 0,
        );
      }).toList();
    });
  }

  Future<void> addProductToCart(String userId, String productId, int quantity) {
    final cartDocRef = _db.collection('users').doc(userId).collection('cart').doc(productId);
    return cartDocRef.set({
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeProductFromCart(String userId, String productId) {
    return _db.collection('users').doc(userId).collection('cart').doc(productId).delete();
  }
  
  Future<void> updateProductQuantityInCart(String userId, String productId, int newQuantity) {
     final cartDocRef = _db.collection('users').doc(userId).collection('cart').doc(productId);
     if (newQuantity > 0) {
        return cartDocRef.update({'quantity': newQuantity});
     } else {
        return removeProductFromCart(userId, productId);
     }
  }
}
