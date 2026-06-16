import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ExpenseCategoryEntity extends Equatable {
  const ExpenseCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String icon;
  final int color;
  final bool isDefault;

  Color get colorValue => Color(color);

  IconData get iconData => switch (icon) {
        'restaurant' => Icons.restaurant_rounded,
        'directions_car' => Icons.directions_car_rounded,
        'shopping_bag' => Icons.shopping_bag_rounded,
        'receipt_long' => Icons.receipt_long_rounded,
        'movie' => Icons.movie_rounded,
        'health' => Icons.health_and_safety_rounded,
        'school' => Icons.school_rounded,
        'more' => Icons.more_horiz_rounded,
        'transport' => Icons.directions_bus_rounded,
        'bills' => Icons.receipt_rounded,
        'entertainment' => Icons.celebration_rounded,
        'food' => Icons.fastfood_rounded,
        _ => Icons.category_rounded,
      };

  ExpenseCategoryEntity copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    bool? isDefault,
  }) {
    return ExpenseCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, isDefault];
}
