import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? id;
  final String name;
  final String email;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, name, email];
}