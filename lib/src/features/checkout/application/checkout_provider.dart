import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/firestore_service.dart';
import '../../authentication/data/auth_service.dart';
import '../../cart/application/cart_provider.dart' show CartProvider;
import '../../profile/domain/address.dart';
import '../domain/bank_account.dart';
import '../domain/shipping_option.dart';

// A model to hold the delivery form data
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

  // A method to check if the essential info is filled
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

  // Loading States
  bool _isInitializing = true;
  bool _isProcessingOrder = false;

  // Data
  List<BankAccount> _bankAccounts = [];
  List<Address> _userAddresses = []; // Added user addresses list
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

  // Selections & Form Data
  ShippingOption? _selectedShipping;
  String _selectedPaymentMethod = 'bank_transfer';
  Address? _selectedAddress;
  final DeliveryInfo _deliveryInfo = DeliveryInfo();
  XFile? _paymentProofImage;

  // Getters
  bool get isInitializing => _isInitializing;
  bool get isProcessingOrder => _isProcessingOrder;
  List<BankAccount> get bankAccounts => _bankAccounts;
  List<Address> get userAddresses => _userAddresses; // Added getter for user addresses
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
    _isInitializing = true;
    notifyListeners();
    _selectedShipping = _shippingOptions.first;
    await _fetchBankAccounts();
    await _fetchUserAddresses(); // Fetch user addresses
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> _fetchBankAccounts() async {
    try {
      _bankAccounts = await _firestoreService.getActiveBankAccounts();
    } catch (e) {
      _bankAccounts = [];
    }
  }

  Future<void> _fetchUserAddresses() async { // Added method to fetch user addresses
    final user = _authService.currentUser;
    if (user != null) {
      try {
        _userAddresses = await _firestoreService.getUserAddresses(user.uid);
      } catch (e) {
        _userAddresses = [];
      }
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
      // empty
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

    try {
      final productsForStockUpdate = _cartProvider.items
          .map((item) => {'productId': item.productId, 'quantity': item.quantity})
          .toList();

      final stockUpdateResult = await _firestoreService.batchUpdateStock(productsForStockUpdate);
      if (!stockUpdateResult) {
        throw Exception('Stok produk tidak mencukupi untuk pesanan ini. Silakan periksa kembali keranjang Anda.');
      }

      String paymentProofUrl = '';
      if (_paymentProofImage != null) {
        paymentProofUrl = await _firestoreService.uploadPaymentProof(
            user.uid, _paymentProofImage!);
      }

      final orderData = {
        'customerId': user.uid,
        'customerDetails': {
          'name': _deliveryInfo.recipientName,
          'address': '${_deliveryInfo.address}, ${_deliveryInfo.city}, ${_deliveryInfo.postalCode}',
          'whatsapp': _deliveryInfo.phoneNumber,
        },
        'products': _cartProvider.items.map((item) => {
          'productId': item.productId,
          'name': item.nama,
          'price': item.harga,
          'quantity': item.quantity,
          'image': item.gambar,
        }).toList(),
        'subtotal': subtotal,
        'shippingFee': shippingCost,
        'total': grandTotal,
        'shippingMethod': _selectedShipping!.name,
        'paymentMethod': _selectedPaymentMethod,
        'paymentProofUrl': paymentProofUrl,
        'paymentStatus': 'Unpaid',
        'status': 'Pending',
        'date': DateTime.now(),
        'stockUpdated': true, 
      };

      await _firestoreService.createOrder(orderData);

      await _cartProvider.fetchCart();

      return null; // Success

    } catch (e) {
      return e.toString();
    } finally {
      _isProcessingOrder = false;
      notifyListeners();
    }
  }
}
