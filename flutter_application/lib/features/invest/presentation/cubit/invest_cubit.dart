import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/invest_repository.dart';
import 'invest_state.dart';

class InvestCubit extends Cubit<InvestState> {
  final InvestRepository repository;

  InvestCubit(this.repository) : super(InvestInitial());

  Future<void> loadStocks() async {
    emit(InvestLoading());
    try {
      final List<Stock> stocks = await repository.getStocks();
      emit(InvestLoaded(stocks)); 
    } catch (e) {
      emit(InvestError(e.toString()));
    }
  }
}
