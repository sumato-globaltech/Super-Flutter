import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get formatted => DateFormat.yMMMd().format(this);

  String get formattedWithTime =>
      '${DateFormat.yMMMd().format(this)}, ${DateFormat.Hm().format(this)}';

  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  bool get isToday => _isSameDay(DateTime.now());

  bool get isYesterday =>
      _isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  bool get isPast => isBefore(DateTime.now());

  bool get isFuture => isAfter(DateTime.now());

  String get relative {
    final difference = DateTime.now().difference(this);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return formatted;
  }

  bool isStalerThan(Duration duration) =>
      DateTime.now().difference(this) > duration;

  bool _isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
