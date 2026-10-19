/// Asset classes (decision D11: pips only for forex and metals).
enum AssetClass {
  forex,
  metals,
  crypto,
  stocks;

  bool get usesPips => this == forex || this == metals;
}

/// Instrument lookup. Step 2 extends this with pip size, precision and
/// contract size (docs/05-domain-and-data.md › Instrument maths).
abstract final class Instruments {
  static const _crypto = {'BTC', 'ETH', 'SOL', 'XRP', 'ADA', 'DOGE', 'BNB'};
  static const _metals = {'XAU', 'XAG', 'XPT', 'XPD'};

  /// Defaults for the Quick log until the user has history; afterwards the
  /// chips show their five most-used instruments by frequency.
  static const starters = [
    'EUR/USD',
    'GBP/USD',
    'USD/JPY',
    'XAU/USD',
    'BTC/USD',
  ];

  /// Normalises user input: trims, upper-cases, and turns "EURUSD" into
  /// "EUR/USD" for six-letter currency pairs.
  static String normalise(String raw) {
    final s = raw.trim().toUpperCase().replaceAll(' ', '');
    if (!s.contains('/') &&
        s.length == 6 &&
        RegExp(r'^[A-Z]{6}$').hasMatch(s)) {
      return '${s.substring(0, 3)}/${s.substring(3)}';
    }
    return s;
  }

  static AssetClass classify(String symbol) {
    final s = normalise(symbol);
    final parts = s.split('/');
    if (parts.length != 2) return AssetClass.stocks; // e.g. AAPL
    final base = parts.first;
    if (_crypto.contains(base)) return AssetClass.crypto;
    if (_metals.contains(base)) return AssetClass.metals;
    return AssetClass.forex;
  }
}
