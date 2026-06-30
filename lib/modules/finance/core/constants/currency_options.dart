class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.label,
    required this.locale,
  });

  final String code;
  final String symbol;
  final String label;
  final String locale;
}

class CurrencyOptions {
  CurrencyOptions._();

  static const String defaultCode = 'USD';

  static const List<CurrencyOption> all = [
    CurrencyOption(
      code: 'USD',
      symbol: '\$',
      label: 'US Dollar',
      locale: 'en_US',
    ),
    CurrencyOption(
      code: 'INR',
      symbol: 'Rs',
      label: 'Indian Rupee',
      locale: 'en_IN',
    ),
    CurrencyOption(
      code: 'EUR',
      symbol: 'EUR',
      label: 'Euro',
      locale: 'en_IE',
    ),
    CurrencyOption(
      code: 'GBP',
      symbol: 'GBP',
      label: 'British Pound',
      locale: 'en_GB',
    ),
  ];

  static CurrencyOption byCode(String? code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => all.first,
    );
  }
}
