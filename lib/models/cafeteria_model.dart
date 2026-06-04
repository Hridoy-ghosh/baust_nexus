class CafeteriaItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final bool available;

  CafeteriaItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.available,
  });

  factory CafeteriaItem.fromMap(Map<String, dynamic> data, String documentId) {
    return CafeteriaItem(
      id: documentId,
      name: data['name'] ?? '',
      category: data['category'] ?? 'All',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '🍽️',
      available: data['available'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'available': available,
    };
  }
}

class CafeteriaOrder {
  final String id;
  final String userId;
  final String userName;
  final String userDept;
  final String? userPhone;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime orderTime;
  final String token;
  final String? bkashNumber;
  final String? nagadNumber;
  final String? transactionId;
  final String? tableNumber;
  final String? floor;
  final DateTime? deliveredTime;

  CafeteriaOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userDept,
    this.userPhone,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.orderTime,
    required this.token,
    this.bkashNumber,
    this.nagadNumber,
    this.transactionId,
    this.tableNumber,
    this.floor,
    this.deliveredTime,
  });

  factory CafeteriaOrder.fromMap(Map<String, dynamic> data, String documentId) {
    return CafeteriaOrder(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userDept: data['userDept'] ?? '',
      userPhone: data['userPhone'],
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      status: data['status'] ?? 'pending',
      orderTime: _parseOrderTime(data['orderTime']),
      token: data['token'] ?? '',
      bkashNumber: data['bkashNumber'],
      nagadNumber: data['nagadNumber'],
      transactionId: data['transactionId'],
      tableNumber: data['tableNumber'],
      floor: data['floor'],
      deliveredTime: data['deliveredTime'] != null ? _parseOrderTime(data['deliveredTime']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userDept': userDept,
      if (userPhone != null) 'userPhone': userPhone,
      'items': items,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'orderTime': orderTime.toIso8601String(),
      'token': token,
      if (bkashNumber != null) 'bkashNumber': bkashNumber,
      if (nagadNumber != null) 'nagadNumber': nagadNumber,
      if (transactionId != null) 'transactionId': transactionId,
      if (tableNumber != null) 'tableNumber': tableNumber,
      if (floor != null) 'floor': floor,
      if (deliveredTime != null) 'deliveredTime': deliveredTime!.toIso8601String(),
    };
  }

  static DateTime _parseOrderTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}