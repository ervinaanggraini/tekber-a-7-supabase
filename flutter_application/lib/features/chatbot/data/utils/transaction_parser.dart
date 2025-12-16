Map<String, dynamic>? parseTransactionFromText(String text) {
  final lower = text.toLowerCase();

  // Keywords indicating spending (pengeluaran)
  final spendingKeywords = RegExp(r'\b(beli|habis|abis|bayar|belanja|jajan|makan|minum|keluar)\b', caseSensitive: false);
  // Keywords indicating income (pemasukan)
  final incomeKeywords = RegExp(r'\b(dapat( uang)?|gaji|bonus|pemasukan|terima(n)?|masuk)\b', caseSensitive: false);

  // Must contain either spending or income-related keyword
  final isSpending = spendingKeywords.hasMatch(lower);
  final isIncome = incomeKeywords.hasMatch(lower);
  if (!isSpending && !isIncome) return null;

  // Find amount (supports 5000, 5.000, 5,000)
  final amountMatch = RegExp(r'(\d+(?:[.,]\d{3})*)').firstMatch(text);
  if (amountMatch == null) return null;

  var amountStr = amountMatch.group(1) ?? '';
  amountStr = amountStr.replaceAll(RegExp(r'[.,]'), '');

  final amountDouble = double.tryParse(amountStr);
  if (amountDouble == null || amountDouble <= 0) return null;
  final amount = (amountDouble % 1 == 0) ? amountDouble.toInt() : amountDouble;
  if (amount == null || amount <= 0) return null;

  // Try to extract item/merchant before the number
  String? item;
  if (isSpending) {
    final itemPattern = RegExp(r'beli\s+([^\d]+?)\s+' + RegExp.escape(amountMatch.group(1) ?? ''), caseSensitive: false);
    final itemMatch = itemPattern.firstMatch(text);
    if (itemMatch != null) {
      item = itemMatch.group(1)?.trim();
    }
  } else if (isIncome) {
    // e.g., "dapat gaji 5000000" or "gaji 5.000.000"
    final incomePattern = RegExp(r'(?:dapat\s+)?([a-zA-Z]+(?:\s[a-zA-Z]+)*)\s+' + RegExp.escape(amountMatch.group(1) ?? ''), caseSensitive: false);
    final incomeMatch = incomePattern.firstMatch(text);
    if (incomeMatch != null) {
      item = incomeMatch.group(1)?.trim();
    }
  }

  if (item == null) {
    // Fallback: take up to 3 words immediately before the amount
    final tokens = text.split(RegExp(r'\s+'));
    final idx = tokens.indexWhere((t) => t.contains(amountMatch.group(1) ?? ''));
    if (idx > 0) {
      final start = (idx - 3) >= 0 ? idx - 3 : 0;
      item = tokens.sublist(start, idx).join(' ').trim();
    }
  }

  return {
    'amount': amount,
    'description': item ?? (isIncome ? 'Pemasukan' : 'Pembelian'),
    'merchant': item,
    'type': isIncome ? 'income' : 'expense',
  };
}

bool isAffirmativeText(String text) {
  final t = text.toLowerCase().trim();
  final yes = RegExp(r'^(ya|iya|oke|ok|yes|y|confirm|lanjut|catat|silakan|ya, catat|iya, catat)', caseSensitive: false);
  return yes.hasMatch(t);
}

bool isNegativeText(String text) {
  final t = text.toLowerCase().trim();
  final no = RegExp(r'^(tidak|ngga|enggak|no|cancel|batal)', caseSensitive: false);
  return no.hasMatch(t);
}
