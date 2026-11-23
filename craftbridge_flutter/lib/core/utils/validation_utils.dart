class ValidationUtils {
  static const List<String> validTrades = [
    'Electrical',
    'Plumbing',
    'Appliance Repair',
    'Cleaning',
  ];

  static final RegExp idPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
  static final RegExp certIdPattern =
      RegExp(r'^(SOFTI|CB)-[0-9]{4}-[A-Z]{2}-[0-9]{3,5}$');
  static final RegExp txnIdPattern = RegExp(r'^TXN-[A-Z0-9-]+$');

  static const int displayNameMax = 80;
  static const int phoneMax = 30;
  static const int neighborhoodMax = 100;
  static const int zoneNameMax = 80;
  static const int bioMax = 400;
  static const int titleMin = 3;
  static const int titleMax = 120;
  static const int descriptionMin = 5;
  static const int descriptionMax = 600;
  static const int trainingDaysMin = 10;
  static const int trainingDaysMax = 30;
  static const int practicalScoreMin = 60;
  static const int practicalScoreMax = 100;
  static const double hourlyRateMin = 10;
  static const double hourlyRateMax = 500;
  static const double budgetMin = 10;
  static const double budgetMax = 5000;
  static const double radiusMinKm = 1;
  static const double radiusMaxKm = 15;
  static const int maxPhotos = 3;

  static String sanitizeText(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  static double clampDouble(double value, double min, double max) {
    if (value.isNaN || value.isInfinite) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static int clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static String maskPhoneNumber(String phone) {
    final cleaned = phone.trim();
    if (cleaned.length <= 4) return '••••';
    return '${cleaned.substring(0, 3)} ••••• ${cleaned.substring(cleaned.length - 4)}';
  }
}
