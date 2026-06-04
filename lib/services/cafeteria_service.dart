import 'dart:async';
import '../models/cafeteria_model.dart';

class CafeteriaService {
  static final List<CafeteriaOrder> _orders = [];
  static final StreamController<List<CafeteriaOrder>> _ordersController = StreamController<List<CafeteriaOrder>>.broadcast();

  static Stream<List<CafeteriaOrder>> streamAllOrders() {
    return Stream<List<CafeteriaOrder>>.multi((controller) {
      controller.add(List.unmodifiable(_orders));
      final subscription = _ordersController.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }

  static Stream<List<CafeteriaOrder>> streamOrdersByUser(String userId) {
    return Stream<List<CafeteriaOrder>>.multi((controller) {
      controller.add(_orders.where((o) => o.userId == userId).toList());
      final subscription = _ordersController.stream.listen((orders) {
        controller.add(orders.where((o) => o.userId == userId).toList());
      });
      controller.onCancel = subscription.cancel;
    });
  }

  static Future<void> addOrder(CafeteriaOrder order) async {
    _orders.insert(0, order);
    _ordersController.add(List.unmodifiable(_orders));
  }

  static void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    final order = _orders[index];
    
    final deliveredTime = newStatus == 'delivered' ? DateTime.now() : order.deliveredTime;
    
    _orders[index] = CafeteriaOrder(
      id: order.id,
      userId: order.userId,
      userName: order.userName,
      userDept: order.userDept,
      userPhone: order.userPhone,
      items: order.items,
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      status: newStatus,
      orderTime: order.orderTime,
      token: order.token,
      bkashNumber: order.bkashNumber,
      nagadNumber: order.nagadNumber,
      transactionId: order.transactionId,
      tableNumber: order.tableNumber,
      floor: order.floor,
      deliveredTime: deliveredTime,
    );
    _ordersController.add(List.unmodifiable(_orders));
  }

  // টেবিল বুকড কিনা চেক করুন (pending এবং delivered উভয়ই চেক করবে)
  static bool isTableBooked(String floor, String tableNumber) {
    // pending অর্ডার চেক করুন
    final pendingOrders = _orders.where((order) => 
      order.status == 'pending' &&
      order.tableNumber == tableNumber &&
      order.floor == floor
    ).toList();
    
    if (pendingOrders.isNotEmpty) {
      return true;
    }
    
    // delivered অর্ডার চেক করুন (শেষ 30 মিনিটের মধ্যে)
    final now = DateTime.now();
    final recentDeliveries = _orders.where((order) => 
      order.status == 'delivered' &&
      order.tableNumber == tableNumber &&
      order.floor == floor &&
      order.deliveredTime != null &&
      now.difference(order.deliveredTime!).inMinutes < 30
    ).toList();
    
    return recentDeliveries.isNotEmpty;
  }

  // available tables লিস্ট পাওয়া
  static List<String> getAvailableTables(String floor, List<String> allTables) {
    final now = DateTime.now();
    
    final busyTables = _orders.where((order) => 
      order.floor == floor &&
      order.tableNumber != null &&
      (
        order.status == 'pending' ||
        (order.status == 'delivered' && 
         order.deliveredTime != null &&
         now.difference(order.deliveredTime!).inMinutes < 30)
      )
    ).map((o) => o.tableNumber).toSet();
    
    return allTables.where((table) => !busyTables.contains(table)).toList();
  }

  static double calculateTotalRevenue(List<CafeteriaOrder> orders) {
    return orders
        .where((o) => o.status == 'delivered')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  static double calculateTodayRevenue(List<CafeteriaOrder> orders) {
    final today = DateTime.now();
    return orders.where((o) =>
        o.status == 'delivered' &&
        o.orderTime.year == today.year &&
        o.orderTime.month == today.month &&
        o.orderTime.day == today.day
    ).fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  static Map<String, int> calculateItemSalesCount(List<CafeteriaOrder> orders) {
    final Map<String, int> sales = {};
    for (var order in orders) {
      if (order.status == 'delivered') {
        for (var item in order.items) {
          final name = item['name'] as String;
          final qty = item['quantity'] as int;
          sales[name] = (sales[name] ?? 0) + qty;
        }
      }
    }
    return sales;
  }
}