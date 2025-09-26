import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String province;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.province,
    required this.isDefault,
  });

  factory Address.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Address(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      province: data['province'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }
}
