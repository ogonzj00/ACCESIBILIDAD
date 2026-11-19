const maxExpenseCents = 99999999999;

int? parseExpense(String input) {
  final match = RegExp(r'^([0-9]{1,9})(?:[,.]([0-9]{1,2}))?$')
      .firstMatch(input.trim());
  if (match == null) return null;
  return int.parse(match.group(1)!) * 100 +
      int.parse((match.group(2) ?? '').padRight(2, '0'));
}

String formatExpense(int cents) =>
    '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
