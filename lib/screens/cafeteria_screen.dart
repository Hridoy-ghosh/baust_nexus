import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../services/cafeteria_service.dart';
import '../models/cafeteria_model.dart';

class CafeteriaScreen extends StatefulWidget {
  const CafeteriaScreen({super.key});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOrdering = false;
  String _searchQuery = '';
  bool _showOnlyAvailable = false;
  String _selectedSortBy = 'Name';
  
  String _selectedDeliveryOption = 'dine-in';
  String _selectedTableNumber = 'Table 1';
  String _selectedFloorNumber = 'Ground Floor';
  String _specialInstructions = '';
  String _selectedPaymentMethod = 'cash';
  bool _couponApplied = false;
  
  final List<String> _groundFloorTables = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6', 'Table 7', 'Table 8', 'Table 9', 'Table 10', 'Table 11', 'Table 12'];
  final List<String> _outdoorTables = ['Outdoor 1', 'Outdoor 2', 'Outdoor 3', 'Outdoor 4', 'Outdoor 5', 'Outdoor 6', 'Outdoor 7', 'Outdoor 8'];
  List<String> _availableTables = [];
  final List<String> _floorNumbers = ['Ground Floor', 'Outdoor Seating'];
  
  final TextEditingController _bkashNumberCtrl = TextEditingController();
  final TextEditingController _bkashPinCtrl = TextEditingController();
  final TextEditingController _nagadNumberCtrl = TextEditingController();
  final TextEditingController _nagadPinCtrl = TextEditingController();
  final TextEditingController _specialInstructionsCtrl = TextEditingController();
  final TextEditingController _couponCodeCtrl = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 250);

  final List<CafeteriaItem> _menuItems = [
    CafeteriaItem(id: '1', name: 'Milk Tea', category: 'Beverages', price: 10, image: '🫖', available: true),
    CafeteriaItem(id: '2', name: 'Coffee', category: 'Beverages', price: 20, image: '☕', available: true),
    CafeteriaItem(id: '10', name: 'Cold Drink', category: 'Beverages', price: 25, image: '🥤', available: true),
    CafeteriaItem(id: '11', name: 'Fresh Juice', category: 'Beverages', price: 30, image: '🧃', available: true),
    CafeteriaItem(id: '28', name: 'Cold Coffee', category: 'Beverages', price: 35, image: '🥤', available: true),
    CafeteriaItem(id: '4', name: 'Biscuits', category: 'Snacks', price: 10, image: '🍪', available: true),
    CafeteriaItem(id: '5', name: 'Samosa', category: 'Snacks', price: 10, image: '🥟', available: true),
    CafeteriaItem(id: '7', name: 'Vegetable Roll', category: 'Snacks', price: 20, image: '🥖', available: true),
    CafeteriaItem(id: '24', name: 'Chicken Roll', category: 'Snacks', price: 50, image: '🌯', available: true),
    CafeteriaItem(id: '25', name: 'French Fries', category: 'Snacks', price: 40, image: '🍟', available: true),
    CafeteriaItem(id: '27', name: 'Momos', category: 'Snacks', price: 60, image: '🥟', available: true),
    CafeteriaItem(id: '6', name: 'Puri', category: 'Breakfast', price: 15, image: '🥟', available: true),
    CafeteriaItem(id: '12', name: 'Bread Toast', category: 'Breakfast', price: 20, image: '🍞', available: true),
    CafeteriaItem(id: '13', name: 'Boiled Egg', category: 'Breakfast', price: 15, image: '🥚', available: true),
    CafeteriaItem(id: '14', name: 'Omelette', category: 'Breakfast', price: 20, image: '🍳', available: true),
    CafeteriaItem(id: '8', name: 'Burger', category: 'Fast Food', price: 55, image: '🍔', available: true),
    CafeteriaItem(id: '9', name: 'Pizza Slice', category: 'Fast Food', price: 60, image: '🍕', available: true),
    CafeteriaItem(id: '26', name: 'Shawarma', category: 'Fast Food', price: 70, image: '🥙', available: true),
    CafeteriaItem(id: '3', name: 'Cake Slice', category: 'Desserts', price: 30, image: '🍰', available: true),
    CafeteriaItem(id: '37', name: 'Ice Cream', category: 'Desserts', price: 40, image: '🍦', available: true),
    CafeteriaItem(id: '30', name: 'Vegetable Salad', category: 'Healthy', price: 45, image: '🥗', available: true),
    CafeteriaItem(id: '15', name: 'Special Biryani', category: 'Special', price: 120, image: '🍛', available: true),
    CafeteriaItem(id: '16', name: 'Chicken Kabab', category: 'Special', price: 90, image: '🍗', available: true),
    CafeteriaItem(id: '17', name: 'Mutton Rezala', category: 'Special', price: 150, image: '🍲', available: true),
    CafeteriaItem(id: '19', name: 'Chowmein Combo', category: 'Special', price: 80, image: '🍜', available: true),
    CafeteriaItem(id: '20', name: 'BBQ Chicken', category: 'Special', price: 130, image: '🍗', available: true),
    CafeteriaItem(id: '23', name: 'Special Thali', category: 'Special', price: 200, image: '🍛', available: true),
  ];

  final List<Map<String, dynamic>> _weeklyMenu = [
    {'day': 'Saturday', 'meal': 'Breakfast', 'description': 'Porota, Dal, Sobji, Egg, Tea', 'price': 45, 'icon': Icons.free_breakfast},
    {'day': 'Saturday', 'meal': 'Lunch', 'description': 'Rice, Fish Curry, Dal, Mixed Vegetable, Salad', 'price': 65, 'icon': Icons.lunch_dining},
    {'day': 'Saturday', 'meal': 'Snacks', 'description': 'Samosa, Singara, Tea/Coffee', 'price': 25, 'icon': Icons.fastfood},
    {'day': 'Saturday', 'meal': 'Special', 'description': 'Special Biryani', 'price': 120, 'icon': Icons.star},
    {'day': 'Sunday', 'meal': 'Breakfast', 'description': 'Ruti, Sobji, Egg, Tea', 'price': 40, 'icon': Icons.free_breakfast},
    {'day': 'Sunday', 'meal': 'Lunch', 'description': 'Rice, Beef Curry, Dal, Bharta, Salad', 'price': 80, 'icon': Icons.lunch_dining},
    {'day': 'Sunday', 'meal': 'Snacks', 'description': 'Pizza Slice, Juice', 'price': 60, 'icon': Icons.fastfood},
    {'day': 'Sunday', 'meal': 'Special', 'description': 'Chicken Kebab', 'price': 90, 'icon': Icons.star},
    {'day': 'Monday', 'meal': 'Breakfast', 'description': 'Chapati, Dal, Egg, Tea', 'price': 35, 'icon': Icons.free_breakfast},
    {'day': 'Monday', 'meal': 'Lunch', 'description': 'Chicken Biryani, Borhani, Salad', 'price': 85, 'icon': Icons.lunch_dining},
    {'day': 'Monday', 'meal': 'Snacks', 'description': 'Burger, Cold Drink', 'price': 55, 'icon': Icons.fastfood},
    {'day': 'Monday', 'meal': 'Special', 'description': 'Mutton Rezala', 'price': 150, 'icon': Icons.star},
    {'day': 'Tuesday', 'meal': 'Breakfast', 'description': 'Puri, Chana, Sweet, Tea', 'price': 45, 'icon': Icons.free_breakfast},
    {'day': 'Tuesday', 'meal': 'Lunch', 'description': 'Rice, Mutton Curry, Dal, Salad, Firni', 'price': 95, 'icon': Icons.lunch_dining},
    {'day': 'Tuesday', 'meal': 'Snacks', 'description': 'Cake, Coffee', 'price': 40, 'icon': Icons.fastfood},
    {'day': 'Tuesday', 'meal': 'Special', 'description': 'Fish Fry Platter', 'price': 100, 'icon': Icons.star},
    {'day': 'Wednesday', 'meal': 'Breakfast', 'description': 'Sandwich, Juice, Fruit', 'price': 55, 'icon': Icons.free_breakfast},
    {'day': 'Wednesday', 'meal': 'Lunch', 'description': 'Rice, Fish Fry, Dal, Mixed Vegetable, Salad', 'price': 70, 'icon': Icons.lunch_dining},
    {'day': 'Wednesday', 'meal': 'Snacks', 'description': 'Chicken Roll, Tea', 'price': 45, 'icon': Icons.fastfood},
    {'day': 'Wednesday', 'meal': 'Special', 'description': 'Chowmein Combo', 'price': 80, 'icon': Icons.star},
    {'day': 'Thursday', 'meal': 'Breakfast', 'description': 'Noodles, Egg, Tea/Coffee', 'price': 45, 'icon': Icons.free_breakfast},
    {'day': 'Thursday', 'meal': 'Lunch', 'description': 'Khichuri, Beef Bhuna, Egg, Pickle', 'price': 75, 'icon': Icons.lunch_dining},
    {'day': 'Thursday', 'meal': 'Snacks', 'description': 'French Fries, Burger, Cold Drink', 'price': 65, 'icon': Icons.fastfood},
    {'day': 'Thursday', 'meal': 'Special', 'description': 'BBQ Chicken', 'price': 130, 'icon': Icons.star},
    {'day': 'Friday', 'meal': 'Breakfast', 'description': 'Special Weekend Breakfast', 'price': 65, 'icon': Icons.free_breakfast},
    {'day': 'Friday', 'meal': 'Lunch', 'description': 'Special Biryani, Kebab, Salad, Dessert', 'price': 110, 'icon': Icons.lunch_dining},
    {'day': 'Friday', 'meal': 'Snacks', 'description': 'Special Snacks Combo', 'price': 75, 'icon': Icons.fastfood},
    {'day': 'Friday', 'meal': 'Special', 'description': 'Weekend Special Thali', 'price': 200, 'icon': Icons.star},
  ];

  final Map<String, int> _cart = {};

  List<CafeteriaItem> get _filteredItems {
    var items = List<CafeteriaItem>.from(_menuItems);
    if (_selectedCategory != 'All') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_showOnlyAvailable) {
      items = items.where((item) => item.available).toList();
    }
    items = items.where((item) => item.price >= _priceRange.start && item.price <= _priceRange.end).toList();
    if (_selectedSortBy == 'Name') {
      items.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedSortBy == 'Price Low to High') {
      items.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSortBy == 'Price High to Low') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }
    return items;
  }

  double get _cartTotal {
    double total = 0;
    _cart.forEach((itemId, quantity) {
      if (itemId.startsWith('weekly_')) {
        for (var w in _weeklyMenu) {
          final weeklyId = 'weekly_${w['day']}_${w['meal']}'.toLowerCase().replaceAll(' ', '_');
          if (weeklyId == itemId) {
            total += (w['price'] as num).toDouble() * quantity;
            break;
          }
        }
      } else {
        final item = _menuItems.firstWhere((i) => i.id == itemId);
        total += item.price * quantity;
      }
    });
    return total;
  }

  double get _taxAmount => _cartTotal * 0.05;
  double get _serviceCharge => _cartTotal * 0.10;
  double get _grandTotal => _cartTotal + _taxAmount + _serviceCharge;
  int get _cartItemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  String _generateToken() => 'CAF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  String _generateTransactionId() => 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

  void _addToCart(String itemId) {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Added to cart!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
    );
  }

  void _addWeeklyToCart(Map<String, dynamic> weeklyItem) {
    final weeklyId = 'weekly_${weeklyItem['day']}_${weeklyItem['meal']}'.toLowerCase().replaceAll(' ', '_');
    setState(() {
      _cart[weeklyId] = (_cart[weeklyId] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ "${weeklyItem['day']} ${weeklyItem['meal']}" added to cart!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
    );
    _tabController.animateTo(1);
  }

  void _increaseQuantity(String itemId) {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(String itemId) {
    setState(() {
      if (_cart[itemId] != null && _cart[itemId]! > 0) {
        _cart[itemId] = _cart[itemId]! - 1;
        if (_cart[itemId] == 0) _cart.remove(itemId);
      }
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      _cart.remove(itemId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Removed from cart'), backgroundColor: Colors.orange, duration: Duration(seconds: 1)),
    );
  }

  void _clearCart() {
    setState(() => _cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cart cleared'), backgroundColor: Colors.orange, duration: Duration(seconds: 1)),
    );
  }

  void _updateAvailableTables() {
    setState(() {
      if (_selectedFloorNumber == 'Ground Floor') {
        _availableTables = CafeteriaService.getAvailableTables(_selectedFloorNumber, _groundFloorTables);
      } else {
        _availableTables = CafeteriaService.getAvailableTables(_selectedFloorNumber, _outdoorTables);
      }
      if (_availableTables.isNotEmpty && !_availableTables.contains(_selectedTableNumber)) {
        _selectedTableNumber = _availableTables.first;
      }
    });
  }

  String _getItemName(String itemId) {
    if (itemId.startsWith('weekly_')) {
      final parts = itemId.replaceFirst('weekly_', '').split('_');
      if (parts.length >= 2) {
        return '${parts[0]} ${parts[1]}';
      }
      return itemId;
    }
    final item = _menuItems.firstWhere((i) => i.id == itemId, orElse: () => CafeteriaItem(id: '', name: itemId, category: '', price: 0, image: '', available: true));
    return item.name;
  }

  double _getItemPrice(String itemId) {
    if (itemId.startsWith('weekly_')) {
      for (var w in _weeklyMenu) {
        final weeklyId = 'weekly_${w['day']}_${w['meal']}'.toLowerCase().replaceAll(' ', '_');
        if (weeklyId == itemId) {
          return (w['price'] as num).toDouble();
        }
      }
      return 0;
    }
    final item = _menuItems.firstWhere((i) => i.id == itemId, orElse: () => CafeteriaItem(id: '', name: '', category: '', price: 0, image: '', available: true));
    return item.price;
  }

  String? _validatePayment() {
    if (_selectedPaymentMethod == 'bkash') {
      final number = _bkashNumberCtrl.text.trim();
      if (number.isEmpty) return 'Please provide bKash number';
      if (!RegExp(r'^01[0-9]{9}$').hasMatch(number)) return 'Enter valid 11-digit bKash number';
    }
    if (_selectedPaymentMethod == 'nagad') {
      final number = _nagadNumberCtrl.text.trim();
      if (number.isEmpty) return 'Please provide Nagad number';
      if (!RegExp(r'^01[0-9]{9}$').hasMatch(number)) return 'Enter valid 11-digit Nagad number';
    }
    return null;
  }

  void _showQRDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('📱 Pay with $type', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(type == 'bKash' ? Icons.qr_code : Icons.qr_code_2, size: 90, color: type == 'bKash' ? Colors.pink : Colors.red),
                const SizedBox(height: 8),
                Text('Scan QR to Pay', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Merchant: BAUST Cafeteria', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ]),
            ),
          ),
        ]),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)), child: const Text('Done', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog(String token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text('✅ Order Placed Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        content: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text('Your Order Token', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('#$token', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green))),
              ),
              const SizedBox(height: 12),
              Text('💰 Token diye khabar nin!', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green), textAlign: TextAlign.center),
              if (_selectedDeliveryOption == 'dine-in') ...[
                const SizedBox(height: 8),
                Text('📍 $_selectedFloorNumber, 🪑 $_selectedTableNumber', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Cart is empty'), backgroundColor: Colors.red));
      return;
    }
    
    if (_selectedDeliveryOption == 'dine-in') {
      if (_selectedTableNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Please select a table number for Dine In'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedFloorNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Please select a floor for Dine In'), backgroundColor: Colors.red),
        );
        return;
      }
      
      if (CafeteriaService.isTableBooked(_selectedFloorNumber, _selectedTableNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ This table is currently booked. Please select another table or wait 30 minutes.'), backgroundColor: Colors.red),
        );
        _updateAvailableTables();
        return;
      }
    }
    
    final validationError = _validatePayment();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationError), backgroundColor: Colors.red));
      return;
    }

    final user = context.read<AuthService>().currentUser;
    final isGuest = user == null;
    final guestId = 'guest-${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isOrdering = true);

    try {
      final items = _cart.entries.map((entry) {
        final itemName = _getItemName(entry.key);
        final itemPrice = _getItemPrice(entry.key);
        return {
          'id': entry.key, 
          'name': itemName, 
          'price': itemPrice, 
          'quantity': entry.value, 
          'subtotal': itemPrice * entry.value,
          'tableNumber': _selectedDeliveryOption == 'dine-in' ? _selectedTableNumber : null,
          'floor': _selectedDeliveryOption == 'dine-in' ? _selectedFloorNumber : null,
        };
      }).toList();

      final token = _generateToken();
      final transactionId = (_selectedPaymentMethod == 'bkash' || _selectedPaymentMethod == 'nagad') ? _generateTransactionId() : null;

      final order = CafeteriaOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: isGuest ? guestId : user!.id,
        userName: isGuest ? 'Guest' : user!.name,
        userDept: isGuest ? 'Guest' : (user!.department ?? 'Unknown'),
        userPhone: isGuest ? null : user!.phoneNumber,
        items: items,
        totalAmount: _grandTotal,
        paymentMethod: _selectedDeliveryOption,
        status: 'pending',
        orderTime: DateTime.now(),
        token: token,
        bkashNumber: _selectedPaymentMethod == 'bkash' ? _bkashNumberCtrl.text.trim() : null,
        nagadNumber: _selectedPaymentMethod == 'nagad' ? _nagadNumberCtrl.text.trim() : null,
        transactionId: transactionId,
        tableNumber: _selectedDeliveryOption == 'dine-in' ? _selectedTableNumber : null,
        floor: _selectedDeliveryOption == 'dine-in' ? _selectedFloorNumber : null,
        deliveredTime: null,
      );

      await CafeteriaService.addOrder(order);
      _clearCart();
      _bkashNumberCtrl.clear();
      _bkashPinCtrl.clear();
      _nagadNumberCtrl.clear();
      _nagadPinCtrl.clear();
      _specialInstructionsCtrl.clear();
      _couponCodeCtrl.clear();
      _couponApplied = false;

      if (!mounted) return;
      _showPaymentSuccessDialog(token);
      _tabController.animateTo(2);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateAvailableTables();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bkashNumberCtrl.dispose();
    _bkashPinCtrl.dispose();
    _nagadNumberCtrl.dispose();
    _nagadPinCtrl.dispose();
    _specialInstructionsCtrl.dispose();
    _couponCodeCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = _cartItemCount;
    const primaryColor = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text('Miritika Cafeteria', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu, size: 20), text: 'Menu'),
            Tab(icon: Icon(Icons.shopping_cart_outlined, size: 20), text: 'Cart'),
            Tab(icon: Icon(Icons.assignment_outlined, size: 20), text: 'Orders'),
          ],
        ),
        actions: [
          if (cartItemCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text('$cartItemCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
            ),
        ],
      ),
      body: _isOrdering ? const Center(child: CircularProgressIndicator(color: primaryColor)) : TabBarView(controller: _tabController, children: [_buildMenuTab(primaryColor), _buildCartTab(primaryColor), _buildOrdersTab()]),
    );
  }

  Widget _buildMenuItem(CafeteriaItem item, Color primaryColor) {
    final qty = _cart[item.id] ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.image,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '৳${item.price.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _addToCart(item.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          if (qty > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$qty in cart',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuTab(Color primaryColor) {
    final categories = ['All', ..._menuItems.map((item) => item.category).toSet()];
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : screenWidth > 640 ? 3 : 2;
    
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.restaurant_menu, color: Colors.white), const SizedBox(width: 8), Text('Miritika Cafeteria', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
              const SizedBox(height: 10),
              Text('Payment kore token nin! Token diye khabar nin!', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.schedule, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text('8:00 AM - 8:00 PM', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 14),
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text('Ground Floor', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))
              ]),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/images/cafeteria.jpeg', width: double.infinity, height: 160, fit: BoxFit.cover)),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search menu items...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { setState(() { _searchQuery = ''; _searchController.clear(); }); }) : null,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Icon(Icons.filter_list, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('Available only', style: TextStyle(fontSize: 12)),
            Switch(value: _showOnlyAvailable, onChanged: (v) => setState(() => _showOnlyAvailable = v), activeColor: primaryColor),
            const Spacer(),
            const Icon(Icons.sort, size: 18, color: Colors.grey),
            const SizedBox(width: 4),
            DropdownButton<String>(
              value: _selectedSortBy,
              items: ['Name', 'Price Low to High', 'Price High to Low'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) => setState(() => _selectedSortBy = v!),
              underline: const SizedBox(),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Price: ৳${_priceRange.start.toInt()} - ৳${_priceRange.end.toInt()}', style: const TextStyle(fontSize: 11)),
              TextButton(onPressed: () => setState(() => _priceRange = const RangeValues(0, 250)), child: const Text('Reset', style: TextStyle(fontSize: 11))),
            ]),
            RangeSlider(values: _priceRange, min: 0, max: 250, divisions: 50, activeColor: primaryColor, onChanged: (values) => setState(() => _priceRange = values)),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Text('Categories', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        ),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat), selected: selected, selectedColor: primaryColor, backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(fontSize: 12, color: selected ? Colors.white : primaryColor, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: primaryColor, width: 1)),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 0.78, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: _filteredItems.length,
            itemBuilder: (ctx, i) => _buildMenuItem(_filteredItems[i], primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(children: [const Icon(Icons.calendar_month, color: Colors.redAccent, size: 22), const SizedBox(width: 8), Text('Weekly Special Menu', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))]),
        ),
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildWeeklyMenuList(primaryColor)),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildWeeklyMenuList(Color primaryColor) {
    final daysOrder = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _weeklyMenu) { final day = item['day'] as String; if (!grouped.containsKey(day)) grouped[day] = []; grouped[day]!.add(item); }
    
    return Column(children: daysOrder.where((day) => grouped.containsKey(day)).map((day) {
      final dayItems = grouped[day]!;
      return Card(
        margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 2,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          collapsedBackgroundColor: Colors.white, backgroundColor: Colors.white,
          title: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, primaryColor.withAlpha(204)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Icon(_weekdayIcon(day), color: Colors.white, size: 22))),
            const SizedBox(width: 12),
            Text(day, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: Text('${dayItems.length} items', style: const TextStyle(fontSize: 10))),
          ]),
          children: dayItems.map((item) {
            final mealColor = _mealColor(item['meal']);
            final qty = _cart['weekly_${day}_${item['meal']}'.toLowerCase().replaceAll(' ', '_')] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [mealColor, mealColor.withAlpha(179)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Center(child: Icon(item['icon'] as IconData, color: Colors.white, size: 20))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['meal'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(item['description'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                ])),
                Column(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: mealColor.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                    child: Text('৳${item['price']}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: mealColor))),
                  const SizedBox(height: 8),
                  if (qty > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Text('$qty in cart', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green))),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () => _addWeeklyToCart(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'ADD TO CART',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
              ]),
            );
          }).toList(),
        ),
      );
    }).toList());
  }

  Widget _buildCartTab(Color primaryColor) {
    if (_cart.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey),
        const SizedBox(height: 12),
        Text('Cart is empty', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => _tabController.animateTo(0), style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: const Text('Browse Menu')),
      ]));
    }
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('🛒 Your Cart (${_cartItemCount} items)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _clearCart, icon: const Icon(Icons.delete_outline, size: 18), label: Text('Clear All', style: TextStyle(color: Colors.red.shade700))),
            ]),
            const SizedBox(height: 12),
            ..._cart.entries.map((entry) {
              final itemName = _getItemName(entry.key);
              final itemPrice = _getItemPrice(entry.key);
              final subtotal = itemPrice * entry.value;
              return Card(
                elevation: 0, margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Container(width: 50, height: 50, decoration: BoxDecoration(color: primaryColor.withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.fastfood, color: primaryColor, size: 24))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(itemName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('৳${itemPrice.toStringAsFixed(0)} each', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('Subtotal: ৳${subtotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: primaryColor)),
                    ])),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFFEEF2F6), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        IconButton(onPressed: () => _decreaseQuantity(entry.key), icon: const Icon(Icons.remove, size: 18), color: primaryColor),
                        Text('${entry.value}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(onPressed: () => _increaseQuantity(entry.key), icon: const Icon(Icons.add, size: 18), color: primaryColor),
                      ]),
                    ),
                    const SizedBox(width: 4),
                    IconButton(onPressed: () => _removeFromCart(entry.key), icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 20), const Divider(), const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('📦 Delivery Options', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedDeliveryOption = 'dine-in'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedDeliveryOption == 'dine-in' ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedDeliveryOption == 'dine-in' ? primaryColor : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dining, size: 20, color: _selectedDeliveryOption == 'dine-in' ? Colors.white : primaryColor),
                            const SizedBox(width: 8),
                            Text('Dine In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _selectedDeliveryOption == 'dine-in' ? Colors.white : primaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedDeliveryOption = 'takeaway'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedDeliveryOption == 'takeaway' ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedDeliveryOption == 'takeaway' ? primaryColor : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag, size: 20, color: _selectedDeliveryOption == 'takeaway' ? Colors.white : primaryColor),
                            const SizedBox(width: 8),
                            Text('Take Away', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _selectedDeliveryOption == 'takeaway' ? Colors.white : primaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
                if (_selectedDeliveryOption == 'dine-in') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('📍 Floor', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: _selectedFloorNumber,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _floorNumbers.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedFloorNumber = v!;
                                _updateAvailableTables();
                              });
                            },
                          ),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('🪑 Table', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: _selectedTableNumber,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _availableTables.map((t) => DropdownMenuItem(value: t, child: Row(children: [
                              Icon(Icons.table_restaurant, size: 14, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(t),
                            ]))).toList(),
                            onChanged: (v) => setState(() => _selectedTableNumber = v!),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  if (_availableTables.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Icon(Icons.warning, size: 16, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'No tables available at $_selectedFloorNumber right now. Please wait 30 minutes or choose another floor.',
                              style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                            ),
                          ),
                        ]),
                      ),
                    ),
                ],
                if (_selectedDeliveryOption == 'takeaway') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Please collect your order from the counter with your token', style: TextStyle(fontSize: 12, color: Colors.green.shade700))),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
            
            const SizedBox(height: 16),
            TextField(controller: _specialInstructionsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: '📝 Special Instructions (Optional)', hintText: 'e.g., Less spicy, No onion...', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), prefixIcon: Icon(Icons.note_add_outlined)), onChanged: (v) => _specialInstructions = v),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
              Expanded(child: TextField(controller: _couponCodeCtrl, decoration: const InputDecoration(hintText: '🎟️ Enter coupon code (SAVE10)', border: InputBorder.none, isDense: true), style: const TextStyle(fontSize: 12))),
              TextButton(onPressed: () {
                if (_couponCodeCtrl.text.trim().toUpperCase() == 'SAVE10') { setState(() => _couponApplied = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Coupon applied! 10% discount'), backgroundColor: Colors.green, duration: Duration(seconds: 1))); }
                else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Invalid coupon code'), backgroundColor: Colors.red, duration: Duration(seconds: 1))); }
              }, child: Text('Apply', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
            ])),
            if (_couponApplied) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.check_circle, size: 14, color: Colors.green), const SizedBox(width: 8), Text('Coupon applied! 10% discount', style: TextStyle(fontSize: 11, color: Colors.green))])),
            ],
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: primaryColor.withAlpha(13), borderRadius: BorderRadius.circular(14), border: Border.all(color: primaryColor.withAlpha(25))), child: Column(children: [
              _billRow('Subtotal', '৳${_cartTotal.toStringAsFixed(0)}'), const SizedBox(height: 6),
              _billRow('VAT (5%)', '৳${_taxAmount.toStringAsFixed(0)}'), const SizedBox(height: 6),
              _billRow('Service Charge (10%)', '৳${_serviceCharge.toStringAsFixed(0)}'),
              if (_couponApplied) ...[const SizedBox(height: 6), _billRow('Coupon Discount', '-৳${(_grandTotal * 0.1).toStringAsFixed(0)}', color: Colors.green)],
              const Divider(height: 16),
              _billRow('Total Payable', '৳${_grandTotal.toStringAsFixed(0)}', isBold: true, color: primaryColor),
            ])),
            const SizedBox(height: 20),
            Text('💳 Select Payment Method', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _paymentChip('💵 Cash', 'cash', Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _paymentChip('📱 bKash', 'bkash', Colors.pink)),
              const SizedBox(width: 10),
              Expanded(child: _paymentChip('📱 Nagad', 'nagad', Colors.red)),
            ]),
            const SizedBox(height: 16),
            if (_selectedPaymentMethod == 'bkash') ...[
              _buildQRButton('bKash'), const SizedBox(height: 10),
              TextField(controller: _bkashNumberCtrl, decoration: const InputDecoration(labelText: 'bKash Wallet Number', hintText: '017XXXXXXXX', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), prefixIcon: Icon(Icons.phone_android)), keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              TextField(controller: _bkashPinCtrl, decoration: const InputDecoration(labelText: 'bKash PIN', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), prefixIcon: Icon(Icons.lock)), obscureText: true, keyboardType: TextInputType.number),
            ],
            if (_selectedPaymentMethod == 'nagad') ...[
              _buildQRButton('Nagad'), const SizedBox(height: 10),
              TextField(controller: _nagadNumberCtrl, decoration: const InputDecoration(labelText: 'Nagad Wallet Number', hintText: '01XXXXXXXXX', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), prefixIcon: Icon(Icons.phone_android)), keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              TextField(controller: _nagadPinCtrl, decoration: const InputDecoration(labelText: 'Nagad PIN', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), prefixIcon: Icon(Icons.lock)), obscureText: true, keyboardType: TextInputType.number),
            ],
            const SizedBox(height: 20),
          ]),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, spreadRadius: 1)]),
        child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: _placeOrder, icon: const Icon(Icons.check_circle_outline, color: Colors.white), label: Text('PLACE ORDER (৳${_grandTotal.toStringAsFixed(0)})', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      )
    ]);
  }

  Widget _billRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color))]));
  }

  Widget _paymentChip(String label, String value, Color color) {
    final selected = _selectedPaymentMethod == value;
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => setState(() => _selectedPaymentMethod = value), backgroundColor: Colors.grey.shade100, selectedColor: color.withAlpha(51), labelStyle: GoogleFonts.poppins(fontSize: 12, color: selected ? color : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: selected ? color : Colors.grey.shade300)));
  }

  Widget _buildQRButton(String type) {
    return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _showQRDialog(type), icon: const Icon(Icons.qr_code_scanner), label: Text('📱 Open QR Code Interface ($type)', style: GoogleFonts.poppins(fontSize: 12)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E3A8A), side: const BorderSide(color: Color(0xFF1E3A8A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12))));
  }

  Widget _buildOrdersTab() {
    final user = context.read<AuthService>().currentUser;
    final userId = user?.id ?? '';
    return StreamBuilder<List<CafeteriaOrder>>(stream: CafeteriaService.streamOrdersByUser(userId), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))); }
      final orders = snapshot.data ?? [];
      if (orders.isEmpty) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey), const SizedBox(height: 12), Text('No order history found', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)), const SizedBox(height: 16), ElevatedButton(onPressed: () => _tabController.animateTo(0), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)), child: const Text('Order Now'))]));
      }
      return ListView.builder(padding: const EdgeInsets.all(16), itemCount: orders.length, itemBuilder: (ctx, i) {
        final order = orders[i];
        final statusColor = _getStatusColor(order.status);
        final isDineIn = order.paymentMethod == 'dine-in' || order.paymentMethod == 'Dine In';
        return Card(margin: const EdgeInsets.only(bottom: 12), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(isDineIn ? Icons.dining : Icons.shopping_bag, size: 16, color: isDineIn ? Colors.blue : Colors.green),
              const SizedBox(width: 8),
              Text('🧾 Token: ${order.token}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withAlpha(25), borderRadius: BorderRadius.circular(20)), child: Text(order.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
          ]),
          const SizedBox(height: 8),
          Text('Total Paid: ৳${order.totalAmount.toStringAsFixed(0)} • ${isDineIn ? 'Dine In' : 'Take Away'}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade800)),
          if (isDineIn && order.tableNumber != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '📍 ${order.floor ?? 'Ground Floor'}, Table: ${order.tableNumber}',
                style: TextStyle(fontSize: 10, color: Colors.blue),
              ),
            ),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...order.items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('• ${item['name']} × ${item['quantity']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)), Text('৳${(item['price'] * item['quantity']).toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))]))),
            const Divider(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)), Text('৳${order.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
          ])),
          const SizedBox(height: 12),
          Text('Ordered on: ${order.orderTime.toString().substring(0, 16)}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ])));
      });
    });
  }

  Color _getStatusColor(String status) {
    switch (status) { case 'pending': return Colors.orange; case 'confirmed': return const Color(0xFF1E3A8A); case 'preparing': return Colors.orange; case 'ready': return Colors.green; case 'delivered': return Colors.green.shade700; default: return Colors.grey; }
  }

  Color _mealColor(String meal) {
    switch (meal.toLowerCase()) { case 'breakfast': return const Color(0xFFF59E0B); case 'lunch': return const Color(0xFF2563EB); case 'snacks': return const Color(0xFFEF4444); case 'special': return const Color(0xFF10B981); default: return const Color(0xFF6B7280); }
  }

  IconData _weekdayIcon(String day) {
    switch (day.toLowerCase()) { case 'monday': return Icons.work; case 'tuesday': return Icons.local_fire_department; case 'wednesday': return Icons.wb_sunny; case 'thursday': return Icons.nightlife; case 'friday': return Icons.weekend; case 'saturday': return Icons.sports_tennis; case 'sunday': return Icons.sunny; default: return Icons.calendar_today; }
  }
}