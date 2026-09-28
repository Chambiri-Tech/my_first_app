import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final ProductModel? product;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: double.parse(json['price'].toString()),
      product: json['product'] != null
          ? ProductModel.fromJson(
              json['product'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  double get subtotal => price*quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        price,
        product,
      ];
}

class CartModel extends Equatable {
  final int id;
  final int userId;
  final List<CartItemModel> items;

  const CartModel({
    required this.id,
    required this.userId,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => CartItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
  
  // Total quantity of all products in the cart
  int get totalItems {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
      ];
}