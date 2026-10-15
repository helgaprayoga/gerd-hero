DateTime localDateOnly([DateTime? value]) {
  final date = value ?? DateTime.now();
  return DateTime(date.year, date.month, date.day);
}

String dateOnlyString(DateTime value) {
  final date = localDateOnly(value);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
