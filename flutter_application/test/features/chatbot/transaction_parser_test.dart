import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/chatbot/data/utils/transaction_parser.dart';

void main() {
  test('parses simple "beli" message', () {
    final input = 'Aku habis beli cilok 5000';
    final parsed = parseTransactionFromText(input);
    expect(parsed, isNotNull);
    expect(parsed!['amount'], 5000);
    expect((parsed['description'] as String).toLowerCase(), contains('cilok'));
  });

  test('parses with dot separators', () {
    final input = 'bayar kopi 12.000 di warung';
    final parsed = parseTransactionFromText(input);
    expect(parsed, isNotNull);
    expect(parsed!['amount'], 12000);
    expect((parsed['description'] as String).toLowerCase(), contains('kopi'));
  });

  test('parses when keyword "habis" used', () {
    final input = 'habis makan di warung 25000';
    final parsed = parseTransactionFromText(input);
    expect(parsed, isNotNull);
    expect(parsed!['amount'], 25000);
    expect((parsed['description'] as String).toLowerCase(), contains('warung'));
  });

  test('returns null when no spending keyword', () {
    final input = 'apa kabar?';
    final parsed = parseTransactionFromText(input);
    expect(parsed, isNull);
  });

  test('parses income when keyword present', () {
    final input = 'Dapat gaji 5.000.000 bulan ini';
    final parsed = parseTransactionFromText(input);
    expect(parsed, isNotNull);
    expect(parsed!['amount'], 5000000);
    expect(parsed['type'], 'income');
    expect((parsed['description'] as String).toLowerCase(), contains('gaji'));
  });

  test('parses income with "dapat uang"', () {
    final input = 'aku dapat uang 2000';
    final parsed = parseTransactionFromText(input);
    expect(parsed, isNotNull);
    expect(parsed!['amount'], 2000);
    expect(parsed['type'], 'income');
  });
}
