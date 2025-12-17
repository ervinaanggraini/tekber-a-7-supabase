import 'package:flutter_bloc/flutter_bloc.dart';
import 'portfolio_state.dart';
import '../../domain/entities/portfolio_item.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit() : super(PortfolioLoading());

  void loadPortfolio() {
    emit(
      PortfolioLoaded(
        totalValue: 13250000,
        totalPercentage: 1.2,
        items: [
          PortfolioItem(
            code: 'BBCA',
            name: 'Bank Central Asia',
            totalUnits: 1002.406,
            totalInvested: 10000000,
            currentValue: 10126000,
          ),
          PortfolioItem(
            code: 'GOTO',
            name: 'GoTo',
            totalUnits: 59090.909,
            totalInvested: 3250000,
            currentValue: 3347825,
          ),
        ],
      ),
    );
  }
}
