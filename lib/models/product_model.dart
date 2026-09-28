import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int? id;
  final String name;
  final double price;
  final int quantity;
  final String? pic;

  const ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.pic,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      pic: json['pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'pic': pic,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        quantity,
        pic,
      ];
}
