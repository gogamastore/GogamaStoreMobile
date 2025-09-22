import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class CartProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  String? _userId;
  Map<String, CartItem> _items = {};
  StreamSubscription<List<CartItem>>? _cartSubscription;

  CartProvider(this._authService, this._firestoreService) {
    // Listen to authentication state changes to update the cart based on the user.
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // --- Getters ---
  Map<String, CartItem> get items => {..._items};

  // The total number of individual items in the cart (respecting quantity)
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.subtotal;
    });
    return total;
  }

  // --- Authentication State Handling ---
  void _onAuthStateChanged(User? user) {
    if (user != null) {
      _userId = user.uid;
      _listenToCart();
    } else {
      _userId = null;
      _items.clear();
      _cartSubscription?.cancel();
      notifyListeners(); // Notify listeners to clear the UI
    }
  }

  void _listenToCart() {
    _cartSubscription?.cancel(); // Cancel any previous subscription
    if (_userId != null) {
      _cartSubscription = _firestoreService.getCartStream(_userId!).listen((cartItems) {
        _items = {for (var item in cartItems) item.product.id: item};
        notifyListeners();
      });
    }
  }

  // --- Cart Operations (delegating to FirestoreService) ---

  Future<void> addItem(Product product, int quantity) async {
    if (_userId == null) return; // Guard against operations when logged out

    final existingItem = _items[product.id];
    final newQuantity = (existingItem?.quantity ?? 0) + quantity;

    await _firestoreService.addProductToCart(_userId!, product.id, newQuantity);
    // The UI will update reactively via the stream, no need to call notifyListeners() here.
  }

  Future<void> updateItemQuantity(String productId, int quantity) async {
    if (_userId == null) return;
    
    if (quantity > 0) {
      await _firestoreService.updateProductQuantityInCart(_userId!, productId, quantity);
    } else {
      // If quantity is 0 or less, remove the item completely
      await removeItem(productId);
    }
  }

  Future<void> removeItem(String productId) async {
    if (_userId == null) return;
    await _firestoreService.removeProductFromCart(_userId!, productId);
  }

  Future<void> clearCart() async {
    if (_userId == null) return;
    
    final cartItemIds = _items.keys.toList();
    // Run all delete operations in parallel for efficiency
    await Future.wait(cartItemIds.map((id) => _firestoreService.removeProductFromCart(_userId!, id)));
  }

  // --- Cleanup ---
  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
