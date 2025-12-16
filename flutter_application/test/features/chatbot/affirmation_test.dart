import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/chatbot/data/utils/transaction_parser.dart';

void main() {
  test('affirmative detector recognizes common yes', () {
    expect(isAffirmativeText('ya'), isTrue);
    expect(isAffirmativeText('iya'), isTrue);
    expect(isAffirmativeText('oke, catat'), isTrue);
  });

  test('negative detector recognizes common no', () {
    expect(isNegativeText('tidak'), isTrue);
    expect(isNegativeText('ngga'), isTrue);
    expect(isNegativeText('batal'), isTrue);
  });
}
