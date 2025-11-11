// Module 10 → 15: Cart Provider (with VAT Calculation, Quantity Support, and Firestore Sync)
// ----------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}


class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => _items;


  int get itemCount => _items.fold(0, (acc, item) => acc + item.quantity);


  double get subtotal =>
      _items.fold(0.0, (acc, item) => acc + (item.price * item.quantity));

  double get vat => subtotal * 0.12; // 12% VAT
  double get totalPriceWithVat => subtotal + vat;

  CartProvider() {
    if (kDebugMode) debugPrint('CartProvider initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _userId = null;
        _items = [];
      } else {
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }


  Future<void> _fetchCart() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _items = [];
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }


  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      if (kDebugMode) debugPrint('Cart saved to Firestore');
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving cart: $e');
    }
  }


  void addItem(String id, String name, double price, [int quantity = 1]) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(id: id, name: name, price: price, quantity: quantity));
    }
    _saveCart();
    notifyListeners();
  }


  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }


  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      _saveCart();
      notifyListeners();
    }
  }


  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': subtotal,
        'vat': vat,
        'totalPrice': totalPriceWithVat,
        'itemCount': itemCount,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Order placed successfully with VAT.');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error placing order: $e');
      rethrow;
    }
  }


  Future<void> clearCart() async {
    _items = [];
    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        if (kDebugMode) debugPrint('Firestore cart cleared.');
      } catch (e) {
        if (kDebugMode) debugPrint('Error clearing Firestore cart: $e');
      }
    } else {
      if (kDebugMode) debugPrint('ClearCart called while no user is logged in.');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
