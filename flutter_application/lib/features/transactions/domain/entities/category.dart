import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String? icon;
  final String? color;
  final bool isSystem;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isSystem,
  });

  @override
  List<Object?> get props => [id, name, type, icon, color, isSystem];
}
