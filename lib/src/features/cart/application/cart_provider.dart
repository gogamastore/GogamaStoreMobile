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
      _firestoreService.getCartStream(_uid!).listen((items) {
        _items = {for (var item in items) item.product.id: item};
        notifyListeners();
      });
    }
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_uid == null) return;

    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }

    _firestoreService.updateCart(_uid!, _items.values.toList());
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_uid == null) return;

    _items.remove(productId);

    _firestoreService.updateCart(_uid!, _items.values.toList());
    notifyListeners();
  }

  void clearCart() {
    if (_uid == null) return;

    _items = {};

    _firestoreService.updateCart(_uid!, []);
    notifyListeners();
  }
}
