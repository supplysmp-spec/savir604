import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _integerFormat = NumberFormat.currency(
    locale: 'en_EG',
    symbol: 'EGP ',
    decimalDigits: 0,
  );

  static final NumberFormat _decimalFormat = NumberFormat.currency(
    locale: 'en_EG',
    symbol: 'EGP ',
    decimalDigits: 2,
  );

  static String egp(num value, {bool decimalsWhenNeeded = true}) {
    final double normalized = value.toDouble();
    if (!decimalsWhenNeeded || normalized == normalized.roundToDouble()) {
      return _integerFormat.format(normalized);
    }
    return _decimalFormat.format(normalized);
  }
}
