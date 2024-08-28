enum DayPart {
  allDay,
  morning,
  afternoon,
  evening,
  night,
}

extension DayPartExt on DayPart {
  String get shortName {
    switch (this) {
      case DayPart.allDay:
        return 'All Day';
      case DayPart.morning:
        return 'Morning';
      case DayPart.afternoon:
        return 'Afternoon';
      case DayPart.evening:
        return 'Evening';
      case DayPart.night:
        return 'Night';
    }
  }
}
