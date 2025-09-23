import 'package:flutter/foundation.dart';

import '../../../core/data/firestore_service.dart';
import '../../products/domain/product.dart';
import '../domain/cart_item.dart';

class CartProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final String? _uid;

  Map<String, CartItem> _items = {};

  CartProvider(this._firestoreService, this._uid) {
    if (_uid != null) {
      _firestoreService.getCartStream(_uid).listen((items) {
        _items = {for (var item in items) item.product.id: item};
        notifyListeners();
      });
    }
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // --- FIX: Modified addItem to accept an optional quantity ---
  void addItem(Product product, {int quantity = 1}) {
    if (_uid == null || quantity <= 0) return;

    if (_items.containsKey(product.id)) {
      // If the item already exists, increase its quantity
      _items.update(
        product.id,
        (existingCartItem) {
          final newQuantity = existingCartItem.quantity + quantity;
          // Clamp the quantity to the available stock
          final validatedQuantity = newQuantity > product.stock ? product.stock : newQuantity;
          return CartItem(
            product: existingCartItem.product,
            quantity: validatedQuantity,
          );
        },
      );
    } else {
      // If the item is new, add it to the cart
      // Clamp the quantity to the available stock
      final validatedQuantity = quantity > product.stock ? product.stock : quantity;
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: validatedQuantity),
      );
    }

    _firestoreService.updateCart(_uid, _items.values.toList());
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_uid == null) return;

    _items.remove(productId);

    _firestoreService.updateCart(_uid, _items.values.toList());
    notifyListeners();
  }

  void updateItemQuantity(String productId, int quantity) {
    if (_uid == null) return;

    if (_items.containsKey(productId)) {
      if (quantity > 0) {
        _items.update(
          productId,
          (existingCartItem) {
            // Clamp the quantity to the available stock
            final validatedQuantity = quantity > existingCartItem.product.stock ? existingCartItem.product.stock : quantity;
            return CartItem(
              product: existingCartItem.product,
              quantity: validatedQuantity,
            );
          },
        );
      } else {
        _items.remove(productId);
      }
      _firestoreService.updateCart(_uid, _items.values.toList());
      notifyListeners();
    }
  }

  void clearCart() {
    if (_uid == null) return;

    _items = {};

    _firestoreService.updateCart(_uid, []);
    notifyListeners();
  }
}
