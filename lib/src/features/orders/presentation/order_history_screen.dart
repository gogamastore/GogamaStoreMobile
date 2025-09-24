import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../authentication/data/auth_service.dart';
import '../domain/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedStatus = 'Belum Proses';

  final Map<String, String> _statusMapping = {
    'Belum Proses': 'Pending',
    'Diproses': 'Processing',
    'Dikirim': 'Delivered',
    'Selesai': 'Completed',
    'Dibatalkan': 'Cancelled',
  };

  final List<String> _statusFilters = [
    'Belum Proses',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildStatusFilter(),
          Expanded(
            child: userId == null
                ? const Center(child: Text('Silakan login untuk melihat riwayat.'))
                : _buildOrderList(userId),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).canvasColor,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pesanan Saya', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Lihat semua riwayat transaksi Anda di sini.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = status == _selectedStatus;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                  });
                }
              },
              backgroundColor: isSelected ? Colors.deepPurple[100] : Colors.grey[100],
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(String userId) {
    final firestoreStatus = _statusMapping[_selectedStatus]!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .where('status', isEqualTo: firestoreStatus)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada pesanan dengan status "$_selectedStatus"',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs.map((doc) => Order.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: orders[index]);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Order Detail Screen
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  _buildStatusChip(order.status),
                ],
              ),
              Text(order.formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Divider(height: 24),
              Text(order.customer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('${order.totalProducts} produk • ${order.formattedTotal}', style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text(order.paymentMethod.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String chipText = status;

    switch (status) {
      case 'Pending':
        chipColor = Colors.orange;
        chipText = 'Belum Proses';
        break;
      case 'Processing':
        chipColor = Colors.blue;
        chipText = 'Diproses';
        break;
      case 'Delivered':
        chipColor = Colors.lightGreen;
        chipText = 'Dikirim';
        break;
      case 'Completed':
        chipColor = Colors.green;
        chipText = 'Selesai';
        break;
      case 'Cancelled':
        chipColor = Colors.red;
        chipText = 'Dibatalkan';
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(chipText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}
