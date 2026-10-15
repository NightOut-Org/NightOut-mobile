import 'package:flutter/services.dart';

class NumericLimitFormatter extends TextInputFormatter {
  final int? maxDigits;
  final int? maxDecimals;

  NumericLimitFormatter({this.maxDigits, this.maxDecimals});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (text.isEmpty) return newValue;

    if (maxDecimals != null && text.contains(',')) {
      text = text.replaceAll(',', '.');
    }

    final allowDecimal = maxDecimals != null;
    final regExp = allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'^\d*$');
    if (!regExp.hasMatch(text)) return oldValue;

    final parts = text.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    if (maxDigits != null && intPart.length > maxDigits!) {
      return oldValue;
    }

    if (decPart != null && maxDecimals != null && decPart.length > maxDecimals!) {
      final trimmed = '$intPart.${decPart.substring(0, maxDecimals!)}';
      return newValue.copyWith(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }

    if (text != newValue.text) {
      return newValue.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    return newValue;
  }
}
