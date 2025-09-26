import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/checkout_provider.dart';

class DeliveryInfoWidget extends StatefulWidget {
  const DeliveryInfoWidget({super.key});

  @override
  State<DeliveryInfoWidget> createState() => _DeliveryInfoWidgetState();
}

class _DeliveryInfoWidgetState extends State<DeliveryInfoWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to manage form fields
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final checkoutProvider = context.read<CheckoutProvider>();
    final deliveryInfo = checkoutProvider.deliveryInfo;

    _nameController = TextEditingController(text: deliveryInfo.recipientName);
    _phoneController = TextEditingController(text: deliveryInfo.phoneNumber);
    _addressController = TextEditingController(text: deliveryInfo.address);
    _cityController = TextEditingController(text: deliveryInfo.city);
    _postalCodeController = TextEditingController(text: deliveryInfo.postalCode);
    _instructionsController = TextEditingController(text: deliveryInfo.specialInstructions);

    // Listen for provider updates to update form fields
    checkoutProvider.addListener(_updateFormFields);
  }

  @override
  void dispose() {
    context.read<CheckoutProvider>().removeListener(_updateFormFields);

    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _updateFormFields() {
    final deliveryInfo = context.read<CheckoutProvider>().deliveryInfo;
    if (_nameController.text != deliveryInfo.recipientName) {
      _nameController.text = deliveryInfo.recipientName;
    }
    if (_phoneController.text != deliveryInfo.phoneNumber) {
      _phoneController.text = deliveryInfo.phoneNumber;
    }
     if (_addressController.text != deliveryInfo.address) {
      _addressController.text = deliveryInfo.address;
    }
     if (_cityController.text != deliveryInfo.city) {
      _cityController.text = deliveryInfo.city;
    }
     if (_postalCodeController.text != deliveryInfo.postalCode) {
      _postalCodeController.text = deliveryInfo.postalCode;
    }
  }

  void _onChanged() {
    context.read<CheckoutProvider>().updateDeliveryInfo(
          recipientName: _nameController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          specialInstructions: _instructionsController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _onChanged, // auto-update provider on any change
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // We'll add the Address Selector here later
           TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Penerima'),
            validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
           ),
           const SizedBox(height: 8),
           TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.phone,
            validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
           ),
           const SizedBox(height: 8),
            TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
            maxLines: 3,
            validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
           ),
           const SizedBox(height: 8),
           Row(
             children: [
               Expanded(
                 child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Kota'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                 ),
               ),
               const SizedBox(width: 8),
                Expanded(
                 child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(labelText: 'Kode Pos'),
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 8),
            TextFormField(
            controller: _instructionsController,
            decoration: const InputDecoration(labelText: 'Catatan Khusus (Opsional)'),
            maxLines: 2,
           ),
        ],
      ),
    );
  }
}

