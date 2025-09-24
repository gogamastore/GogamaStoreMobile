import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductItem {
  final String image;
  final String name;
  final int price;
  final String productId;
  final int quantity;

  ProductItem({
    required this.image,
    required this.name,
    required this.price,
    required this.productId,
    required this.quantity,
  });

  factory ProductItem.fromMap(Map<String, dynamic> data) {
    return ProductItem(
      image: data['image'] ?? '',
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0).toInt(),
      productId: data['productId'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
    );
  }
}

class Order {
  final String id;
  final String customer;
  final Map<String, dynamic> customerDetails;
  final Timestamp date;
  final String paymentMethod;
  final String? paymentProofUrl;
  final String paymentStatus;
  final List<ProductItem> products;
  final int shippingFee;
  final String shippingMethod;
  final String status;
  final int subtotal;
  final String total;

  Order({
    required this.id,
    required this.customer,
    required this.customerDetails,
    required this.date,
    required this.paymentMethod,
    this.paymentProofUrl,
    required this.paymentStatus,
    required this.products,
    required this.shippingFee,
    required this.shippingMethod,
    required this.status,
    required this.subtotal,
    required this.total,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var productList = (data['products'] as List<dynamic>?) ?? [];

    return Order(
      id: doc.id,
      customer: data['customerDetails']?['name'] ?? 'N/A',
      customerDetails: (data['customerDetails'] as Map<String, dynamic>?) ?? {},
      date: data['date'] ?? Timestamp.now(),
      paymentMethod: data['paymentMethod'] ?? 'N/A',
      paymentProofUrl: data['paymentProofUrl'],
      paymentStatus: data['paymentStatus'] ?? 'Unknown',
      products: productList.map((p) => ProductItem.fromMap(p as Map<String, dynamic>)).toList(),
      shippingFee: (data['shippingFee'] ?? 0).toInt(),
      shippingMethod: data['shippingMethod'] ?? 'N/A',
      status: data['status'] ?? 'Unknown',
      subtotal: (data['subtotal'] ?? 0).toInt(),
      total: data['total']?.toString() ?? 'Rp 0',
    );
  }

  int get totalProducts => products.fold(0, (sum, item) => sum + item.quantity);
  
  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date.toDate());
  }

  String get formattedTotal {
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return numberFormat.format(subtotal + shippingFee);
  }
}
