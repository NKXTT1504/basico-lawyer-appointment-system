/// Utility class to map between backend slot numbers and frontend time ranges
class SlotMapper {
  /// Map from slot number (string "1", "2", "3", "4") to time range string
  static const Map<String, String> slotToTimeRange = {
    '1': '08:00 - 10:00',
    '2': '10:00 - 12:00',
    '3': '13:00 - 15:00',
    '4': '15:00 - 17:00',
  };

  /// Map from time range string to slot number (string "1", "2", "3", "4")
  static const Map<String, String> timeRangeToSlot = {
    '08:00 - 10:00': '1',
    '10:00 - 12:00': '2',
    '13:00 - 15:00': '3',
    '15:00 - 17:00': '4',
    // Also support alternate formats that might be used
    '08:00 ~ 10:00': '1',
    '10:00 ~ 12:00': '2',
    '13:00 ~ 15:00': '3',
    '15:00 ~ 17:00': '4',
  };

  /// Convert slot number (string "1"-"4") to time range for display
  /// Returns the slot number as-is if it's already a time range or invalid
  static String slotToTime(String? slot) {
    if (slot == null || slot.isEmpty) return '';

    // If it's already a time range, return as-is
    if (timeRangeToSlot.containsKey(slot)) {
      return slot;
    }

    // Try to map slot number to time range
    return slotToTimeRange[slot] ?? slot;
  }

  /// Convert time range string to slot number for backend
  /// Returns the time range as-is if it's already a slot number or invalid
  static String timeToSlot(String? timeRange) {
    if (timeRange == null || timeRange.isEmpty) return '';

    // If it's already a slot number (1-4), return as-is
    if (slotToTimeRange.containsKey(timeRange)) {
      return timeRange;
    }

    // Try to map time range to slot number
    return timeRangeToSlot[timeRange] ?? timeRange;
  }

  /// Get all available time ranges in order
  static List<String> get allTimeRanges => [
        '08:00 - 10:00',
        '10:00 - 12:00',
        '13:00 - 15:00',
        '15:00 - 17:00',
      ];

  /// Check if a string is a slot number (1-4)
  static bool isSlotNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    return slotToTimeRange.containsKey(value);
  }

  /// Check if a string is a time range
  static bool isTimeRange(String? value) {
    if (value == null || value.isEmpty) return false;
    return timeRangeToSlot.containsKey(value);
  }
}
