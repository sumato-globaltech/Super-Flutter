extension StringX on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCased => split(
    RegExp(r'[\s_-]+'),
  ).where((word) => word.isNotEmpty).map((word) => word.capitalized).join(' ');

  String get initials {
    final words = trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength).trimRight()}$ellipsis';
  }

  int? get toIntOrNull => int.tryParse(this);

  double? get toDoubleOrNull => double.tryParse(this);
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  bool get isNotNullOrBlank => !isNullOrBlank;

  String orEmpty() => this ?? '';
}
