import '../../domain/entities/stock.dart';

abstract class InvestState {}

class InvestInitial extends InvestState {}

class InvestLoading extends InvestState {}

class InvestLoaded extends InvestState {
  final List<Stock> stocks;

  InvestLoaded(this.stocks);
}

class InvestError extends InvestState {
  final String message;

  InvestError(this.message);
}
