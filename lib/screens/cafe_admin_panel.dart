import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/cafeteria_model.dart';
import '../services/cafeteria_service.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import 'query_board_screen.dart';

class CafeAdminPanel extends StatefulWidget {
  const CafeAdminPanel({super.key});

  @override
  State<CafeAdminPanel> createState() => _CafeAdminPanelState();
}

class _CafeAdminPanelState extends State<CafeAdminPanel> {
  int _selectedIndex = -1;

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goBack() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    
    if (user?.role != 'admin' || user?.department != 'Cafe') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Only Cafe Admin can access this panel'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ]),
        ),
      );
    }

    if (_selectedIndex != -1) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0 ? 'Cafeteria Management' : 'Query Board',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF1A237E),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body: _selectedIndex == 0
            ? const CafeManagementScreenContent()
            : const QueryBoardScreen(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Cafeteria Admin Panel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 30, color: Color(0xFF1A237E)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        user?.name ?? 'Cafe Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ADMIN • CAFETERIA',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.restaurant,
                    title: 'Cafeteria',
                    subtitle: 'Management',
                    color: const Color(0xFF2196F3),
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.question_answer,
                    title: 'Query',
                    subtitle: 'Board',
                    color: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CAFETERIA MANAGEMENT SCREEN ====================
class CafeManagementScreenContent extends StatefulWidget {
  const CafeManagementScreenContent({super.key});

  @override
  State<CafeManagementScreenContent> createState() => _CafeManagementScreenContentState();
}

class _CafeManagementScreenContentState extends State<CafeManagementScreenContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    CafeteriaService.updateOrderStatus(orderId, newStatus);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Order ${newStatus == 'delivered' ? 'Delivered' : 'Updated'}'), backgroundColor: AppColors.success, duration: const Duration(seconds: 1)),
    );
  }

  void _deleteOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order deleted'), backgroundColor: AppColors.warning),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: '📊 Dashboard'),
              Tab(text: '⏳ Pending'),
              Tab(text: '✅ Orders'),
              Tab(text: '✏️ Menu'),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<CafeteriaOrder>>(
        stream: CafeteriaService.streamAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allOrders = snapshot.data ?? [];
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(allOrders, primaryColor),
              _buildPendingTab(allOrders, primaryColor),
              _buildOrdersTab(allOrders, primaryColor),
              _buildEditMenuTab(primaryColor),
            ],
          );
        },
      ),
    );
  }

  // ==================== DASHBOARD TAB ====================
  Widget _buildDashboardTab(List<CafeteriaOrder> orders, Color primaryColor) {
    final today = DateTime.now();
    
    final todayOrders = orders.where((o) => 
      o.status == 'delivered' &&
      o.orderTime.year == today.year &&
      o.orderTime.month == today.month &&
      o.orderTime.day == today.day
    ).toList();
    final todayRevenue = todayOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final todayOrderCount = todayOrders.length;
    
    final deliveredOrders = orders.where((o) => o.status == 'delivered').toList();
    final totalRevenue = deliveredOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final totalOrders = orders.length;
    final deliveredCount = deliveredOrders.length;
    final pendingCount = orders.where((o) => o.status == 'pending').length;
    final preparingCount = orders.where((o) => o.status == 'preparing').length;
    final readyCount = orders.where((o) => o.status == 'ready').length;
    
    final Map<String, int> itemSales = {};
    for (var order in deliveredOrders) {
      for (var item in order.items) {
        final name = item['name'] as String;
        final qty = item['quantity'] as int;
        itemSales[name] = (itemSales[name] ?? 0) + qty;
      }
    }
    final topItems = itemSales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    final dineInRevenue = deliveredOrders.where((o) => o.paymentMethod == 'dine-in' || o.paymentMethod == 'Dine In').fold(0.0, (sum, o) => sum + o.totalAmount);
    final takeawayRevenue = deliveredOrders.where((o) => o.paymentMethod == 'takeaway' || o.paymentMethod == 'Take Away').fold(0.0, (sum, o) => sum + o.totalAmount);
    
    final todayDineIn = todayOrders.where((o) => o.paymentMethod == 'dine-in' || o.paymentMethod == 'Dine In').fold(0.0, (sum, o) => sum + o.totalAmount);
    final todayTakeaway = todayOrders.where((o) => o.paymentMethod == 'takeaway' || o.paymentMethod == 'Take Away').fold(0.0, (sum, o) => sum + o.totalAmount);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Income Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.today, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('TODAY\'S INCOME', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('৳${todayRevenue.toStringAsFixed(0)}', 
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('$todayOrderCount orders completed', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Dine: ৳${todayDineIn.toStringAsFixed(0)}', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(width: 12),
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Take: ৳${todayTakeaway.toStringAsFixed(0)}', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: Colors.white30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.attach_money, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('TOTAL INCOME', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('৳${totalRevenue.toStringAsFixed(0)}', 
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${deliveredCount} total deliveries', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Dine: ৳${dineInRevenue.toStringAsFixed(0)}', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(width: 12),
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Take: ৳${takeawayRevenue.toStringAsFixed(0)}', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Order Statistics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Statistics', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildOrderStatCard('Total', totalOrders.toString(), Icons.receipt_long, Colors.grey)),
                    Expanded(child: _buildOrderStatCard('Pending', pendingCount.toString(), Icons.pending, Colors.orange)),
                    Expanded(child: _buildOrderStatCard('Preparing', preparingCount.toString(), Icons.kitchen, Colors.blue)),
                    Expanded(child: _buildOrderStatCard('Ready', readyCount.toString(), Icons.check_circle_outline, Colors.teal)),
                    Expanded(child: _buildOrderStatCard('Delivered', deliveredCount.toString(), Icons.check_circle, Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Revenue by Type
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.dining, size: 28, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text('Dine In', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('৳${dineInRevenue.toStringAsFixed(0)}', 
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('Total Revenue', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.shopping_bag, size: 28, color: Colors.green),
                      const SizedBox(height: 4),
                      Text('Take Away', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('৳${takeawayRevenue.toStringAsFixed(0)}', 
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Total Revenue', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Top Selling Items
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🥇 Top Selling Items', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                (topItems.isEmpty)
                ? Center(child: Text('No sales yet', style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topItems.length > 10 ? 10 : topItems.length,
                    itemBuilder: (ctx, i) {
                      final item = topItems[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.key, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text('${item.value} sold', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recent Orders
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🕐 Recent Orders', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                (orders.isEmpty)
                ? Center(child: Text('No orders yet', style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length > 10 ? 10 : orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orders[i];
                      final isDineIn = order.paymentMethod == 'dine-in' || order.paymentMethod == 'Dine In';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDineIn ? Colors.blue.shade50 : Colors.green.shade50,
                            child: Icon(isDineIn ? Icons.dining : Icons.shopping_bag, size: 18, color: isDineIn ? Colors.blue : Colors.green),
                          ),
                          title: Text('Token: ${order.token}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                          subtitle: Text('${order.userName} • ${isDineIn ? 'Dine In' : 'Take Away'} • ৳${order.totalAmount.toStringAsFixed(0)}', 
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                          trailing: Chip(
                            label: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 9, color: _getStatusColor(order.status), fontWeight: FontWeight.w500)),
                            backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildOrderStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==================== PENDING TAB ====================
  Widget _buildPendingTab(List<CafeteriaOrder> orders, Color primaryColor) {
    final pendingOrders = orders.where((o) => o.status == 'pending').toList();
    
    if (pendingOrders.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green.shade300),
          const SizedBox(height: 16),
          Text('No pending orders!', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ]),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pendingOrders.length,
      itemBuilder: (ctx, i) {
        final order = pendingOrders[i];
        final isDineIn = order.paymentMethod == 'dine-in' || order.paymentMethod == 'Dine In';
        final tableNumber = order.tableNumber;
        final floor = order.floor;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Token: ${order.token}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
                ),
              ]),
              const SizedBox(height: 8),
              Text('${order.userName} • ${order.userDept}', style: TextStyle(fontSize: 12)),
              if (isDineIn && tableNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('📍 ${floor ?? 'Ground Floor'}, Table: $tableNumber', style: TextStyle(fontSize: 11, color: Colors.blue)),
                ),
              const Divider(height: 16),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${item['quantity']}x ${item['name']}', style: TextStyle(fontSize: 12)),
                  Text('৳${(item['price'] * item['quantity']).toStringAsFixed(0)}', style: TextStyle(fontSize: 12)),
                ]),
              )),
              const Divider(height: 16),
              Text('Total: ৳${order.totalAmount.toStringAsFixed(0)} • ${isDineIn ? 'Dine In' : 'Take Away'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order.id, 'delivered'),
                    icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                    label: const Text('Approve & Deliver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteOrder(order.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                  tooltip: 'Delete Order',
                ),
              ]),
            ]),
          ),
        );
      },
    );
  }

  // ==================== ORDERS TAB ====================
  Widget _buildOrdersTab(List<CafeteriaOrder> orders, Color primaryColor) {
    final deliveredOrders = orders.where((o) => o.status == 'delivered').toList();
    
    if (deliveredOrders.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No delivered orders', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ]),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: deliveredOrders.length,
      itemBuilder: (ctx, i) {
        final order = deliveredOrders[i];
        final isDineIn = order.paymentMethod == 'dine-in' || order.paymentMethod == 'Dine In';
        final tableNumber = order.tableNumber;
        final floor = order.floor;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDineIn ? Colors.blue.shade50 : Colors.green.shade50,
              child: Icon(isDineIn ? Icons.dining : Icons.shopping_bag, size: 20, color: isDineIn ? Colors.blue : Colors.green),
            ),
            title: Text('Token: ${order.token}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${order.userName} • ${isDineIn ? 'Dine In' : 'Take Away'}', style: TextStyle(fontSize: 11)),
                Text('৳${order.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                if (isDineIn && tableNumber != null)
                  Text('📍 ${floor ?? 'Ground Floor'}, Table: $tableNumber', style: TextStyle(fontSize: 10, color: Colors.blue)),
              ],
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green),
              IconButton(
                onPressed: () => _deleteOrder(order.id),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                tooltip: 'Delete Order',
              ),
            ]),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Order Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Token: ${order.token}'),
                    Text('Customer: ${order.userName}'),
                    Text('Department: ${order.userDept}'),
                    Text('Type: ${isDineIn ? 'Dine In' : 'Take Away'}'),
                    if (isDineIn && tableNumber != null) Text('${floor ?? 'Ground Floor'}, Table: $tableNumber'),
                    const Divider(),
                    ...order.items.map((item) => Text('${item['quantity']}x ${item['name']} - ৳${(item['price'] * item['quantity']).toStringAsFixed(0)}')),
                    const Divider(),
                    Text('Total: ৳${order.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== EDIT MENU TAB ====================
  Widget _buildEditMenuTab(Color primaryColor) {
    final TextEditingController _itemNameCtrl = TextEditingController();
    final TextEditingController _itemPriceCtrl = TextEditingController();
    String _selectedCategory = 'Snacks';
    final List<String> _categories = ['Beverages', 'Snacks', 'Breakfast', 'Fast Food', 'Desserts', 'Healthy', 'Special'];
    
    final Map<String, List<Map<String, String>>> _menuItems = {
      'Beverages': [
        {'name': 'Milk Tea', 'price': '10'},
        {'name': 'Coffee', 'price': '20'},
        {'name': 'Cold Drink', 'price': '25'},
        {'name': 'Fresh Juice', 'price': '30'},
        {'name': 'Cold Coffee', 'price': '35'},
      ],
      'Snacks': [
        {'name': 'Biscuits', 'price': '10'},
        {'name': 'Samosa', 'price': '10'},
        {'name': 'Vegetable Roll', 'price': '20'},
        {'name': 'Chicken Roll', 'price': '50'},
        {'name': 'French Fries', 'price': '40'},
        {'name': 'Momos', 'price': '60'},
      ],
      'Breakfast': [
        {'name': 'Puri', 'price': '15'},
        {'name': 'Bread Toast', 'price': '20'},
        {'name': 'Boiled Egg', 'price': '15'},
        {'name': 'Omelette', 'price': '20'},
      ],
      'Fast Food': [
        {'name': 'Burger', 'price': '55'},
        {'name': 'Pizza Slice', 'price': '60'},
        {'name': 'Shawarma', 'price': '70'},
      ],
      'Desserts': [
        {'name': 'Cake Slice', 'price': '30'},
        {'name': 'Ice Cream', 'price': '40'},
      ],
      'Healthy': [
        {'name': 'Vegetable Salad', 'price': '45'},
      ],
      'Special': [
        {'name': 'Special Biryani', 'price': '120'},
        {'name': 'Chicken Kabab', 'price': '90'},
        {'name': 'Mutton Rezala', 'price': '150'},
        {'name': 'BBQ Chicken', 'price': '130'},
        {'name': 'Special Thali', 'price': '200'},
      ],
    };
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('➕ Add New Menu Item', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _itemNameCtrl,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.restaurant, size: 18),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _itemPriceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (৳)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.money, size: 18),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.category, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_itemNameCtrl.text.isNotEmpty && _itemPriceCtrl.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ "${_itemNameCtrl.text}" added'), backgroundColor: AppColors.success),
                    );
                    _itemNameCtrl.clear();
                    _itemPriceCtrl.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ Please fill all fields'), backgroundColor: AppColors.error),
                    );
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ]),
        ),
        
        const SizedBox(height: 24),
        
        Text('📋 Current Menu Items', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        ..._categories.map((category) => _buildCategorySection(category, _menuItems[category] ?? [], primaryColor)),
        
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, String>> items, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(_getCategoryIcon(category), size: 20, color: primaryColor),
            const SizedBox(width: 8),
            Text(category, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor)),
            const Spacer(),
            Text('${items.length} items', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => _buildMenuItemChip(item['name']!, item['price']!, primaryColor)).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _buildMenuItemChip(String name, String price, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.restaurant, size: 12, color: Colors.grey),
        const SizedBox(width: 6),
        Text(name, style: TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text('৳$price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
        const SizedBox(width: 6),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Item'),
                content: Text('Are you sure you want to delete "$name"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🗑️ "$name" deleted'), backgroundColor: AppColors.warning),
                      );
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          child: const Icon(Icons.close, size: 14, color: Colors.red),
        ),
      ]),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Beverages': return Icons.local_cafe;
      case 'Snacks': return Icons.fastfood;
      case 'Breakfast': return Icons.free_breakfast;
      case 'Fast Food': return Icons.lunch_dining;
      case 'Desserts': return Icons.cake;
      case 'Healthy': return Icons.spa;
      case 'Special': return Icons.star;
      default: return Icons.restaurant;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'confirmed': return AppColors.primary;
      case 'preparing': return Colors.orange;
      case 'ready': return AppColors.success;
      case 'delivered': return Colors.green.shade700;
      default: return Colors.grey;
    }
  }
}