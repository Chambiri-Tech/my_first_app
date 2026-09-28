import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthModel extends Equatable {
  final UserModel user;
  final String token;

  const AuthModel({
    required this.user,
    required this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserModel.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }

  @override
  List<Object?> get props => [user, token];
}