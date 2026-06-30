import 'package:intl/intl.dart';
import 'package:mindloop/modules/finance/core/constants/currency_options.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPreferences {
  CurrencyPreferences._();

  static const _key = 'settings.currency.code';

  static SharedPreferences get _prefs => sl<SharedPreferences>();

  static CurrencyOption get selectedOption {
    final code = _prefs.getString(_key) ?? CurrencyOptions.defaultCode;
    return CurrencyOptions.byCode(code);
  }

  static Future<void> setSelectedCode(String code) async {
    await _prefs.setString(_key, code);
  }

  static NumberFormat formatter({int decimalDigits = 0}) {
    final option = selectedOption;
    return NumberFormat.currency(
      locale: option.locale,
      symbol: option.symbol,
      decimalDigits: decimalDigits,
    );
  }
}
