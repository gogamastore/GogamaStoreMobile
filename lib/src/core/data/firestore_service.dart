import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

import '../../features/products/domain/product.dart';
import '../../features/cart/domain/cart_item.dart';
import '../../features/products/domain/banner_item.dart';
import '../../features/products/domain/brand.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _getDownloadUrl(String gsUri) async {
    if (gsUri.startsWith('gs://')) {
      try {
        final ref = _storage.refFromURL(gsUri);
        return await ref.getDownloadURL();
      } catch (e) {
        developer.log('Error getting download URL for $gsUri', name: 'FirestoreService', error: e);
        return ''; 
      }
    }
    return gsUri;
  }

  Future<Product> _transformProduct(Product product) async {
    final imageUrl = await _getDownloadUrl(product.imageUrl);
    return Product(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: imageUrl,
      category: product.category,
      stock: product.stock,
    );
  }
  
  Future<Brand> _transformBrand(Brand brand) async {
    final logoUrl = await _getDownloadUrl(brand.logoUrl);
    return Brand(
      name: brand.name,
      logoUrl: logoUrl,
    );
  }

  Stream<List<BannerItem>> getBannersStream() {
    return _db
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BannerItem.fromMap(doc.data())).toList());
  }

  Stream<List<Brand>> getBrandsStream() {
    return _db
        .collection('brands')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Brand.fromMap(doc.data())).toList())
        .asyncMap((brands) => Future.wait(brands.map(_transformBrand)));
  }

  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    }).asyncMap((products) => Future.wait(products.map(_transformProduct)));
  }

  Stream<List<Product>> getTrendingProductsStream() {
    return _db.collection('trending_products').snapshots().switchMap((snapshot) {
      final productIds = snapshot.docs.map((doc) => doc['productId'] as String).toList();

      if (productIds.isEmpty) {
        return Stream.value([]);
      }

      final productStreams = productIds.map((id) {
        return _db.collection('products').doc(id).snapshots().asyncMap((doc) async {
          if (!doc.exists) return null;
          final product = Product.fromFirestore(doc);
          return await _transformProduct(product);
        });
      });

      return CombineLatestStream.list(productStreams)
          .map((products) => products.where((p) => p != null).cast<Product>().toList());
    });
  }

  Future<Product?> getProduct(String id) async {
    final snapshot = await _db.collection('products').doc(id).get();
    if (snapshot.exists) {
      final product = Product.fromFirestore(snapshot);
      return await _transformProduct(product);
    }
    return null;
  }

  // --- CART METHODS (REBUILT TO MIMIC REACT NATIVE SUCCESS) ---

  Future<Map<String, dynamic>> getUserCart(String uid) async {
    final cartSnapshot = await _db.collection('user').doc(uid).collection('cart').get();

    if (cartSnapshot.docs.isEmpty) {
      return {'items': [], 'total': 0.0};
    }

    double total = 0;
    List<Map<String, dynamic>> items = [];

    for (var cartDoc in cartSnapshot.docs) {
      final data = cartDoc.data();
      final productId = data['product_id'] ?? cartDoc.id;
      final quantity = data['quantity'] as int;

      final productDoc = await _db.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final product = await _transformProduct(Product.fromFirestore(productDoc));
        total += product.price * quantity;
        items.add({
          'id': cartDoc.id,
          'productId': product.id,
          'nama': product.name,
          'harga': product.price,
          'quantity': quantity,
          'gambar': product.imageUrl,
          'stok': product.stock,
        });
      }
    }
    return {'items': items, 'total': total};
  }

  Future<void> setCartItem(String uid, CartItem item) {
    final docRef = _db.collection('user').doc(uid).collection('cart').doc(item.product.id);
    
    return docRef.set({
      'product_id': item.product.id,
      'nama': item.product.name,
      'harga': item.product.price,
      'gambar': item.product.imageUrl,
      'quantity': item.quantity,
      'updated_at': FieldValue.serverTimestamp(), 
    }, SetOptions(merge: true));
  }

  Future<void> updateCartItemQuantity(String uid, String productId, int newQuantity) async {
    if (newQuantity < 1) {
      return removeCartItem(uid, productId);
    }
    final docRef = _db.collection('user').doc(uid).collection('cart').doc(productId);
    return docRef.update({'quantity': newQuantity});
  }

  Future<void> removeCartItem(String uid, String productId) {
    final docRef = _db.collection('user').doc(uid).collection('cart').doc(productId);
    return docRef.delete();
  }

  Future<void> clearCart(String uid) async {
    final cartCollection = _db.collection('user').doc(uid).collection('cart');
    final snapshot = await cartCollection.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    return batch.commit();
  }
}
