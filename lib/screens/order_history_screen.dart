

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Stream to listen to this user's orders
  Stream<QuerySnapshot>? _ordersStream;

  @override
  void initState() {
    super.initState();
    _initOrdersStream();
  }

  // 2. Initialize the orders stream safely
  void _initOrdersStream() {
    final user = _auth.currentUser;
    if (user != null) {
      _ordersStream = _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _ordersStream = null;
    }
    if (kDebugMode) {
      debugPrint('Order history stream initialized for user: ${user?.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: _ordersStream == null
          ? const Center(child: Text('Please log in to view your orders.'))
          : StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          // 3. Handle states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading orders: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          }

          final orders = snapshot.data!.docs;

          // 4. Build the list of order cards
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData =
                  order.data() as Map<String, dynamic>? ?? {};
              final createdAt = orderData['createdAt'] as Timestamp?;
              final totalPrice = (orderData['totalPrice'] ?? 0).toDouble();
              final itemCount = orderData['itemCount'] ?? 0;
              final status = orderData['status'] ?? 'Pending';
              final formattedDate = createdAt != null
                  ? DateFormat('MM/dd/yyyy hh:mm a')
                  .format(createdAt.toDate())
                  : 'Unknown date';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'Items: $itemCount | ₱${totalPrice.toStringAsFixed(2)}\nDate: $formattedDate',
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: status == 'Pending'
                        ? Colors.orange
                        : status == 'Processing'
                        ? Colors.blue
                        : status == 'Shipped'
                        ? Colors.deepPurple
                        : status == 'Delivered'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
