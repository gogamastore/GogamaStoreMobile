import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/firestore_service.dart';
import '../../authentication/data/auth_service.dart';
import '../../cart/application/cart_provider.dart' show CartProvider;
import '../../profile/domain/address.dart';
import '../domain/bank_account.dart';
import '../domain/shipping_option.dart';

class DeliveryInfo {
  String recipientName;
  String phoneNumber;
  String address;
  String city;
  String postalCode;
  String specialInstructions;

  DeliveryInfo({
    this.recipientName = '',
    this.phoneNumber = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
    this.specialInstructions = '',
  });

  bool get isCompleted =>
      recipientName.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      address.isNotEmpty &&
      city.isNotEmpty &&
      postalCode.isNotEmpty;
}

class CheckoutProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final CartProvider _cartProvider;

  bool _isInitializing = true;
  bool _isProcessingOrder = false;

  List<BankAccount> _bankAccounts = [];
  List<Address> _userAddresses = [];
  final List<ShippingOption> _shippingOptions = [
    ShippingOption(
      id: 'courier',
      name: 'Pengiriman oleh Kurir',
      price: 15000,
      estimatedDays: '1-3 hari',
      description: 'Pengiriman menggunakan kurir, harga mulai dari Rp 15.000/koli',
    ),
    ShippingOption(
      id: 'pickup',
      name: 'Ambil di Toko',
      price: 0,
      estimatedDays: 'Hari ini',
      description: 'Ambil sendiri di toko, tidak ada biaya pengiriman',
    ),
  ];

  ShippingOption? _selectedShipping;
  String _selectedPaymentMethod = 'bank_transfer';
  Address? _selectedAddress;
  final DeliveryInfo _deliveryInfo = DeliveryInfo();
  XFile? _paymentProofImage;

  bool get isInitializing => _isInitializing;
  bool get isProcessingOrder => _isProcessingOrder;
  List<BankAccount> get bankAccounts => _bankAccounts;
  List<Address> get userAddresses => _userAddresses;
  List<ShippingOption> get shippingOptions => _shippingOptions;
  ShippingOption? get selectedShipping => _selectedShipping;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  Address? get selectedAddress => _selectedAddress;
  DeliveryInfo get deliveryInfo => _deliveryInfo;
  XFile? get paymentProofImage => _paymentProofImage;

  double get subtotal => _cartProvider.total;
  double get shippingCost => _selectedShipping?.price ?? 0;
  double get grandTotal => subtotal + shippingCost;

  CheckoutProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
    required CartProvider cartProvider,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _cartProvider = cartProvider;

  Future<void> initialize() async {
    developer.log('Initializing CheckoutProvider...', name: 'CheckoutProvider');
    _isInitializing = true;
    notifyListeners();
    _selectedShipping = _shippingOptions.first;
    await _fetchBankAccounts();
    await _fetchUserAddresses(); // This will now auto-select the default address
    _isInitializing = false;
    developer.log('Initialization complete. Found ${_userAddresses.length} addresses.', name: 'CheckoutProvider');
    notifyListeners();
  }

  Future<void> _fetchBankAccounts() async {
    try {
      _bankAccounts = await _firestoreService.getBankAccounts();
    } catch (e) {
      _bankAccounts = [];
      developer.log('Error fetching bank accounts', name: 'CheckoutProvider', error: e);
    }
  }

  Future<void> _fetchUserAddresses() async {
    final user = _authService.currentUser;
    if (user != null) {
      developer.log('Fetching addresses for user: ${user.uid}', name: 'CheckoutProvider');
      try {
        _userAddresses = await _firestoreService.getUserAddresses(user.uid);
        developer.log('Successfully fetched ${_userAddresses.length} addresses.', name: 'CheckoutProvider');
        
        Address? defaultAddress;
        try {
          defaultAddress = _userAddresses.firstWhere((addr) => addr.isDefault);
        } catch (e) {
          if (_userAddresses.isNotEmpty) {
            defaultAddress = _userAddresses.first;
          }
        }

        if (defaultAddress != null) {
          selectSavedAddress(defaultAddress);
        }
      } catch (e, s) {
        _userAddresses = [];
        developer.log('Error fetching user addresses', name: 'CheckoutProvider', error: e, stackTrace: s);
      }
    } else {
       developer.log('Cannot fetch addresses: User is not logged in.', name: 'CheckoutProvider');
       _userAddresses = [];
    }
  }

  void selectShippingOption(ShippingOption option) {
    if (_selectedShipping?.id == option.id) return;
    _selectedShipping = option;

    if (option.id == 'courier' && _selectedPaymentMethod == 'cod') {
      _selectedPaymentMethod = 'bank_transfer';
    }
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    if (_selectedPaymentMethod == method) return;
    
    if (method == 'cod' && _selectedShipping?.id == 'courier') {
      return;
    }

    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void selectSavedAddress(Address address) {
    _selectedAddress = address;
    _deliveryInfo.recipientName = address.name;
    _deliveryInfo.phoneNumber = address.phone;
    _deliveryInfo.address = address.address;
    _deliveryInfo.city = address.city;
    _deliveryInfo.postalCode = address.postalCode;
    notifyListeners();
  }

  void clearSelectedAddress() {
    _selectedAddress = null;
    _deliveryInfo.recipientName = '';
    _deliveryInfo.phoneNumber = '';
    _deliveryInfo.address = '';
    _deliveryInfo.city = '';
    _deliveryInfo.postalCode = '';
    notifyListeners();
  }

  void updateDeliveryInfo({
    String? recipientName,
    String? phoneNumber,
    String? address,
    String? city,
    String? postalCode,
    String? specialInstructions,
  }) {
    _deliveryInfo.recipientName = recipientName ?? _deliveryInfo.recipientName;
    _deliveryInfo.phoneNumber = phoneNumber ?? _deliveryInfo.phoneNumber;
    _deliveryInfo.address = address ?? _deliveryInfo.address;
    _deliveryInfo.city = city ?? _deliveryInfo.city;
    _deliveryInfo.postalCode = postalCode ?? _deliveryInfo.postalCode;
    _deliveryInfo.specialInstructions = specialInstructions ?? _deliveryInfo.specialInstructions;
    // When manual update occurs, deselect the saved address
    _selectedAddress = null;
    notifyListeners();
  }

  Future<void> pickPaymentProof() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        _paymentProofImage = image;
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error picking payment proof', name: 'CheckoutProvider', error: e);
    }
  }

  void removePaymentProof() {
    _paymentProofImage = null;
    notifyListeners();
  }

  Future<String?> processOrder() async {
    final user = _authService.currentUser;
    if (user == null || !_deliveryInfo.isCompleted || _cartProvider.items.isEmpty) {
      return 'Formulir tidak lengkap atau keranjang kosong.';
    }

    _isProcessingOrder = true;
    notifyListeners();

    final String newOrderId = _firestoreService.getNewOrderId();

    try {
      final now = DateTime.now();
      final isoTimestamp = now.toUtc().toIso8601String();

      String paymentProofUrl = '';
      if (_paymentProofImage != null) {
        paymentProofUrl = await _firestoreService.uploadPaymentProof(
            user.uid, newOrderId, _paymentProofImage!);
      }

      final orderData = {
        // Timestamps & Dates
        'created_at': isoTimestamp,
        'updated_at': isoTimestamp,
        'date': now,
        'stockUpdateTimestamp': isoTimestamp,

        // Customer Info
        'customer': _deliveryInfo.recipientName,
        'customerId': user.uid,
        'customerDetails': {
          'name': _deliveryInfo.recipientName,
          'address': '${_deliveryInfo.address}, ${_deliveryInfo.city}, ${_deliveryInfo.postalCode}',
          'whatsapp': _deliveryInfo.phoneNumber,
        },

        // Product Info
        'products': _cartProvider.items.map((item) => {
          'productId': item.productId,
          'name': item.nama,
          'price': item.harga,
          'quantity': item.quantity,
          'image': item.gambar,
        }).toList(),
        'productIds': _cartProvider.items.map((item) => item.productId).toList(),

        // Payment Info
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': _paymentProofImage != null ? 'Paid' : 'Unpaid',
        'paymentProofUrl': paymentProofUrl,
        'paymentProofFileName': _paymentProofImage?.name ?? '',
        'paymentProofId': '', // Left blank as per structure
        'paymentProofUploaded': _paymentProofImage != null,

        // Shipping Info
        'shippingMethod': _selectedShipping!.name,
        'shippingFee': shippingCost,

        // Totals
        'subtotal': subtotal,
        'total': grandTotal,

        // Status
        'status': 'Pending',
        'stockUpdated': true,
      };

      final itemsToUpdate = _cartProvider.items
          .map((item) => {'productId': item.productId, 'quantity': item.quantity})
          .toList();

      await _firestoreService.placeOrderInTransaction(newOrderId, orderData, itemsToUpdate);

      await _cartProvider.clearCart();

      return null; // Success

    } catch (e) {
      developer.log('Error processing order', name: 'CheckoutProvider', error: e);
      return e.toString();
    } finally {
      _isProcessingOrder = false;
      notifyListeners();
    }
  }
}
