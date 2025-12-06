import 'package:shared_preferences/shared_preferences.dart';

class RefIdService {
  // Keys for saving data to phone storage
  static const String _keyLastDate = 'last_report_date';
  static const String _keyCount = 'daily_report_count';

  /// Call this function to get the full formatted ID (e.g., "2526120601")
  static Future<String> generateUniqueId() async {
    // 1. Get the Sequence Number
    int seqNumber = await _getNextSequence();

    // 2. Get current date
    DateTime now = DateTime.now();

    // 3. Calculate Financial Year (FY)
    // If Month is Jan(1), Feb(2), or Mar(3), FY started last year.
    int startYear = (now.month < 4) ? now.year - 1 : now.year;
    int endYear = startYear + 1;

    // Format FY as "2526" (last 2 digits of start and end year)
    String fyString =
        "${startYear.toString().substring(2)}${endYear.toString().substring(2)}";

    // 4. Format Month and Day
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');

    // 5. Format Sequence (Two digits, e.g., 01, 02)
    String seqString = seqNumber.toString().padLeft(2, '0');

    // Combine everything
    return "$fyString$month$day$seqString";
  }

  /// Internal helper to manage the daily counter
  static Future<int> _getNextSequence() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayString =
        "${now.year}-${now.month}-${now.day}"; // e.g., "2025-12-06"

    final lastDate = prefs.getString(_keyLastDate);
    final lastCount = prefs.getInt(_keyCount) ?? 0;

    int newCount;

    // Reset counter if it's a new day
    if (lastDate == todayString) {
      newCount = lastCount + 1;
    } else {
      newCount = 1;
      await prefs.setString(_keyLastDate, todayString);
    }

    await prefs.setInt(_keyCount, newCount);
    return newCount;
  }
}
