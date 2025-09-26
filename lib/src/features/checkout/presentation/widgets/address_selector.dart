import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/firestore_service.dart'; // Corrected Path
import '../../../authentication/data/auth_service.dart';
import '../../../profile/domain/address.dart';
import '../../application/checkout_provider.dart';

class AddressSelector extends StatelessWidget {
  const AddressSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final checkoutProvider = context.watch<CheckoutProvider>();

    return FutureBuilder<List<Address>>(
      future: firestore.getUserAddresses(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Don't show a big spinner, just a small one.
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // No addresses to show, render nothing.
        }

        final addresses = snapshot.data!;

        // Ensure selectedAddress from provider is a valid object from the list
        Address? currentSelection;
        if (checkoutProvider.selectedAddress != null) {
          currentSelection = addresses.firstWhere((a) => a.id == checkoutProvider.selectedAddress!.id, orElse: () => addresses.first);
        } else {
          currentSelection = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
          // Auto-select the default or first address
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<CheckoutProvider>().selectSavedAddress(currentSelection!);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Alamat Tersimpan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Address>(
              value: currentSelection,
              hint: const Text('Pilih dari alamat Anda'),
              isExpanded: true,
              onChanged: (Address? newValue) {
                if (newValue != null) {
                  context.read<CheckoutProvider>().selectSavedAddress(newValue);
                }
              },
              items: addresses.map<DropdownMenuItem<Address>>((Address address) {
                return DropdownMenuItem<Address>(
                  value: address,
                  child: Text('${address.name} - ${address.address}, ${address.city}', overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              decoration: InputDecoration(
                 border: const OutlineInputBorder(),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 suffix: checkoutProvider.selectedAddress != null 
                 ? IconButton(
                   icon: const Icon(Icons.clear, size: 20),
                   onPressed: () => context.read<CheckoutProvider>().clearSelectedAddress(),
                 )
                 : null,
              ),
            ),
             const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
