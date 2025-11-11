// Module 16 → Fixed Cart Clear Timing
// ------------------------------------

import 'package:flutter/material.dart';
import 'package:my_app/providers/cart_provider.dart';
import 'package:my_app/screens/order_success_screen.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processPayment(BuildContext dialogContext) async {
    final cart = Provider.of<CartProvider>(dialogContext, listen: false);
    setState(() => _isProcessing = true);

    try {
      await cart.placeOrder();

      if (!mounted) return;
      _controller.forward();

      await showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Payment Successful!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 70),
                  SizedBox(height: 12),
                  Text(
                    "Your order has been confirmed.\nThank you for shopping!",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // ✅ Clear cart only after user clicks Continue
                    await cart.clearCart();

                    // Then navigate to success screen
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacement(
                      dialogContext,
                      MaterialPageRoute(
                        builder: (_) => const OrderSuccessScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _isProcessing ? null : () => _processPayment(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Amount: ₱${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Choose Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.credit_card,
              label: "Credit / Debit Card",
              context: context,
            ),
            _buildPaymentOption(
              icon: Icons.account_balance_wallet,
              label: "E-Wallet (GCash, Maya, etc.)",
              context: context,
            ),
            _buildPaymentOption(
              icon: Icons.attach_money,
              label: "Cash on Delivery",
              context: context,
            ),
            const Spacer(),
            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            else
              const Center(
                child: Text(
                  "All payments are simulated for demo purposes.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
