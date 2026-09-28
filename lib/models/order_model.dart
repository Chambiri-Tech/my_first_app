import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'] as int,
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        price,
        quantity,
        subtotal,
      ];
}

class OrderModel extends Equatable {
  final int id;
  final int userId;
  final String orderNumber;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      orderNumber: json['order_number'] as String,
      subtotal: double.parse(json['subtotal'].toString()),
      discount: double.parse(json['discount'].toString()),
      total: double.parse(json['total'].toString()),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => OrderItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        orderNumber,
        subtotal,
        discount,
        total,
        status,
        paymentMethod,
        paymentStatus,
        items,
      ];
}