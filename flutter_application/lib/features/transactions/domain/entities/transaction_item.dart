class TransactionItem {
  final String id;
  final String transactionId;
  final String name;
  final int quantity;
  final double price;

  const TransactionItem({
    required this.id,
    required this.transactionId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}