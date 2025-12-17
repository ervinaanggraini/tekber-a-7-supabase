class PortfolioItem {
  final String code;          // BBCA
  final String name;          // Bank Central Asia
  final double totalUnits;    // jumlah lot/unit
  final double totalInvested; // total uang dibeli
  final double currentValue; // nilai sekarang

  PortfolioItem({
    required this.code,
    required this.name,
    required this.totalUnits,
    required this.totalInvested,
    required this.currentValue,
  });

  double get profitPercent {
    if (totalInvested == 0) return 0;
    return ((currentValue - totalInvested) / totalInvested) * 100;
  }
}
