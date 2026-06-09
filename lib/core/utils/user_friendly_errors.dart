/// Turns raw exceptions into short messages suitable for SnackBars.
class UserFriendlyErrors {
  UserFriendlyErrors._();

  static String format(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length).trim();
    }
    return raw.isEmpty ? 'Something went wrong. Please try again.' : raw;
  }
}
