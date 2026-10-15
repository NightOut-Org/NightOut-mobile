class PasswordRuleResult {
  const PasswordRuleResult({
    required this.hasMinLength,
    required this.hasLetterAndDigit,
    required this.hasNoForbiddenRun,
    required this.matchesConfirm,
  });

  final bool hasMinLength;
  final bool hasLetterAndDigit;
  final bool hasNoForbiddenRun;
  final bool matchesConfirm;

  bool get isValid => hasMinLength && hasLetterAndDigit && hasNoForbiddenRun && matchesConfirm;
}

abstract final class PasswordRules {
  static const minLength = 6;
  static const runLength = 4;

  static PasswordRuleResult evaluate(String password, String confirm) {
    return PasswordRuleResult(
      hasMinLength: password.length >= minLength,
      hasLetterAndDigit: _hasLetterAndDigit(password),
      hasNoForbiddenRun: password.isNotEmpty && !_hasRepeatRun(password) && !_hasSequentialRun(password),
      matchesConfirm: password.isNotEmpty && password == confirm,
    );
  }

  static bool _hasLetterAndDigit(String value) {
    return RegExp(r'[A-Za-z]').hasMatch(value) && RegExp(r'[0-9]').hasMatch(value);
  }

  static bool _hasRepeatRun(String value) {
    if (value.length < runLength) return false;
    for (var i = 0; i <= value.length - runLength; i++) {
      final first = value[i];
      var same = true;
      for (var j = 1; j < runLength; j++) {
        if (value[i + j] != first) {
          same = false;
          break;
        }
      }
      if (same) return true;
    }
    return false;
  }

  static bool _hasSequentialRun(String value) {
    if (value.length < runLength) return false;
    final normalized = value.toLowerCase();
    for (var i = 0; i <= normalized.length - runLength; i++) {
      if (_isRun(normalized, i, 1) || _isRun(normalized, i, -1)) return true;
    }
    return false;
  }

  static bool _isRun(String value, int start, int direction) {
    for (var j = 0; j < runLength - 1; j++) {
      final current = value.codeUnitAt(start + j);
      final next = value.codeUnitAt(start + j + 1);
      if (!_sameAlphanumericClass(current, next)) return false;
      if (next - current != direction) return false;
    }
    return true;
  }

  static bool _sameAlphanumericClass(int a, int b) {
    final digits = _isDigit(a) && _isDigit(b);
    final letters = _isLetter(a) && _isLetter(b);
    return digits || letters;
  }

  static bool _isDigit(int code) => code >= 48 && code <= 57;

  static bool _isLetter(int code) => code >= 97 && code <= 122;
}
