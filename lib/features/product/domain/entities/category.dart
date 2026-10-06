import 'package:equatable/equatable.dart';

/// A group of products, such as "Boissons" or "Épicerie".
class Category extends Equatable {
  final String id;
  final String name;

  const Category({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
