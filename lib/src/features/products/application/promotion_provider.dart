import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/data/firestore_service.dart';
import '../domain/promotion.dart';

/// A provider that manages the state of active promotions throughout the app.
class PromotionProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _promoSubscription;

  Map<String, Promotion> _promotions = {};
  bool _isLoading = true;

  PromotionProvider(this._firestoreService) {
    _listenToPromotions();
  }

  /// Returns true if the provider is currently loading promotion data.
  bool get isLoading => _isLoading;

  /// Returns a map of all active promotions, with product ID as the key.
  Map<String, Promotion> get promotions => _promotions;

  /// Gets the active promotion for a specific product ID, if one exists.
  Promotion? getPromotionForProduct(String productId) {
    return _promotions[productId];
  }

  /// Listens to the stream of promotion data from Firestore and updates the state.
  void _listenToPromotions() {
    _isLoading = true;
    notifyListeners();

    _promoSubscription = _firestoreService.getPromoProductsStream().listen((promoProducts) {
      final newPromos = <String, Promotion>{};
      // Create a map for quick lookup of promotions by product ID.
      for (final promoProduct in promoProducts) {
        newPromos[promoProduct.product.id] = promoProduct.promotion;
      }
      _promotions = newPromos;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
      // Optionally, log the error.
    });
  }

  @override
  void dispose() {
    _promoSubscription?.cancel();
    super.dispose();
  }
}
