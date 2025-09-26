import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../application/checkout_provider.dart';
import '../../cart/application/cart_provider.dart';
import '../../authentication/data/auth_service.dart';
import '../../../core/data/firestore_service.dart';
import 'widgets/delivery_info_widget.dart';
import 'widgets/address_selector.dart';
import 'widgets/payment_method_widget.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
        cartProvider: context.read<CartProvider>(),
      )..initialize(),
      child: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          if (checkoutProvider.isInitializing) {
            return Scaffold(
              appBar: AppBar(title: const Text('Checkout')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Builder( // Wrap with Builder
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text('Checkout'),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressSelectorSection(context),
                      const SizedBox(height: 24),
                      _buildOrderSummary(context),
                      const SizedBox(height: 24),
                      _buildShippingOptions(context),
                      const SizedBox(height: 24),
                      _buildDeliveryInfoSection(context),
                      const SizedBox(height: 24),
                      _buildPaymentMethodSection(context),
                    ],
                  ),
                ),
                bottomNavigationBar: _buildCheckoutSummary(context),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddressSelectorSection(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();
    if (checkoutProvider.userAddresses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pilih Alamat Tersimpan'),
        const AddressSelector(),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ringkasan Pesanan'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return ListTile(
              leading: Image.network(item.gambar, width: 50, height: 50, fit: BoxFit.cover),
              title: Text(item.nama),
              subtitle: Text('${item.quantity} x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(item.harga)}'),
              trailing: Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(item.quantity * item.harga)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShippingOptions(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pilih Pengiriman'),
        ...checkoutProvider.shippingOptions.map((option) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(option.name),
              subtitle: Text('${option.description}\nEstimasi: ${option.estimatedDays}'),
              secondary: Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(option.price)),
              value: option.id,
              groupValue: checkoutProvider.selectedShipping?.id,
              onChanged: (value) {
                if (value != null) {
                  context.read<CheckoutProvider>().selectShippingOption(option);
                }
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDeliveryInfoSection(BuildContext context) {
     final checkoutProvider = context.watch<CheckoutProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(checkoutProvider.userAddresses.isEmpty 
          ? 'Isi Alamat Pengiriman' 
          : 'Atau Isi Alamat Pengiriman Baru'),
        const DeliveryInfoWidget(),
      ],
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Metode Pembayaran'),
        const PaymentMethodWidget(),
      ],
    );
  }

  Widget _buildCheckoutSummary(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();
    final total = checkoutProvider.grandTotal;

    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                  Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(checkoutProvider.subtotal), style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pengiriman:', style: TextStyle(fontSize: 16)),
                  Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(checkoutProvider.shippingCost), style: const TextStyle(fontSize: 16)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: checkoutProvider.isProcessingOrder
                    ? null
                    : () async {
                        final error = await context.read<CheckoutProvider>().processOrder();
                        if (context.mounted) {
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
                            context.go('/');
                          }
                        }
                      },
                child: checkoutProvider.isProcessingOrder
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text('Buat Pesanan'),
              ),
            ],
          ),
        );
      },
    );
  }
}
