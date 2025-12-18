import 'package:equatable/equatable.dart';
import '../../domain/entities/portfolio_item.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final double totalValue;
  final double totalPercentage;
  final List<PortfolioItem> items;

  const PortfolioLoaded({
    required this.totalValue,
    required this.totalPercentage,
    required this.items,
  });

  @override
  List<Object?> get props => [totalValue, items];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
}
