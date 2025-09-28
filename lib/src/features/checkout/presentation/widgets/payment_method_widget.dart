import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';

import '../../application/checkout_provider.dart';

class PaymentMethodWidget extends StatelessWidget {
  const PaymentMethodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();
    final isCourierSelected = checkoutProvider.selectedShipping?.id == 'courier';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank Transfer Option
        RadioListTile<String>(
          title: const Text('Transfer Bank'),
          subtitle: const Text('Transfer ke salah satu rekening kami'),
          value: 'bank_transfer',
          groupValue: checkoutProvider.selectedPaymentMethod,
          onChanged: (value) {
            if (value != null) {
              context.read<CheckoutProvider>().selectPaymentMethod(value);
            }
          },
        ),
        if (checkoutProvider.selectedPaymentMethod == 'bank_transfer')
          _buildBankTransferDetails(context),

        // COD Option
        RadioListTile<String>(
          title: Text('COD (Bayar di Tempat)', style: TextStyle(color: isCourierSelected ? Colors.grey : null)),
          subtitle: Text('Siapkan uang pas saat pengambilan${isCourierSelected ? '\n(Tidak tersedia untuk pengiriman kurir)' : ''}', style: TextStyle(color: isCourierSelected ? Colors.grey : null)),
          value: 'cod',
          groupValue: checkoutProvider.selectedPaymentMethod,
          onChanged: isCourierSelected ? null : (value) {
            if (value != null) {
              context.read<CheckoutProvider>().selectPaymentMethod(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferDetails(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(13), // Corrected: Replaced withOpacity
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withAlpha(51)), // Corrected: Replaced withOpacity
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Silakan transfer ke rekening berikut:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...checkoutProvider.bankAccounts.map((account) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: Text(account.bankName),
                  subtitle: Text('${account.accountNumber}\na/n ${account.accountHolder}'),
                ),
              )),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Unggah Bukti Pembayaran (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildPaymentProofUploader(context),
        ],
      ),
    );
  }

  Widget _buildPaymentProofUploader(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();
    final image = checkoutProvider.paymentProofImage;

    if (image != null) {
      return Column(
        children: [
          Stack(
            children: [
              Image.file(File(image.path), height: 150, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => context.read<CheckoutProvider>().removePaymentProof(),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return DottedBorder(
      color: Colors.grey,
      strokeWidth: 1,
      dashPattern: const [6, 6],
      radius: const Radius.circular(8),
      borderType: BorderType.RRect,
      child: InkWell(
        onTap: () => context.read<CheckoutProvider>().pickPaymentProof(),
        child: const SizedBox( // Corrected: Replaced Container with SizedBox
          height: 100,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: Colors.grey),
              SizedBox(height: 8),
              Text('Pilih Gambar', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
