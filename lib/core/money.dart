/// Prices are stored as integer cents to avoid floating-point rounding errors
/// (e.g. 0.1 + 0.2 != 0.3). They are only converted to text for display.
String formatCents(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';