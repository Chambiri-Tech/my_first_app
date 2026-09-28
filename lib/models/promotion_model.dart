import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  final int id;
  final String name;
  final String code;
  final String type;
  final double value;
  final double minimumAmount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  const PromotionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.value,
    required this.minimumAmount,
    this.startsAt,
    this.expiresAt,
    this.usageLimit,
    required this.usedCount,
    required this.isActive,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      value: double.parse(json['value'].toString()),
      minimumAmount:
          double.parse(json['minimum_amount'].toString()),
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'].toString())
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      usageLimit: json['usage_limit'] != null
          ? json['usage_limit'] as int
          : null,
      usedCount: json['used_count'] as int,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  bool get isPercentage => type == 'percentage';

  bool get isFixed => type == 'fixed';

  String get formattedValue {
    if (isPercentage) {
      return '${value.toStringAsFixed(0)}%';
    }

    return value.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    type,
    value,
    minimumAmount,
    startsAt,
    expiresAt,
    usageLimit,
    usedCount,
    isActive,
  ];
}