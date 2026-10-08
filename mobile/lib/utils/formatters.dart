import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Formatters {
  static String formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    num value = 0;
    if (amount is num) {
      value = amount;
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    }
    
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (_) {
      return dateStr.split('T').first;
    }
  }

  static String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateTimeStr);
      final formatter = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');
      return formatter.format(date.toLocal());
    } catch (_) {
      return dateTimeStr;
    }
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    int selectionIndex = newValue.selection.end;

    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    final double value = double.parse(digits);
    final formatter = NumberFormat.decimalPattern('id_ID');
    final String newText = formatter.format(value);

    int newSelectionIndex = newText.length;
    
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int currentDigitCount = 0;
    int indexInNewText = 0;
    for (int i = 0; i < newText.length; i++) {
      if (RegExp(r'\d').hasMatch(newText[i])) {
        currentDigitCount++;
      }
      if (currentDigitCount == digitsBeforeCursor) {
        indexInNewText = i + 1;
        break;
      }
    }
    
    if (digitsBeforeCursor > 0 && indexInNewText > 0) {
      newSelectionIndex = indexInNewText;
    } else if (digitsBeforeCursor == 0) {
      newSelectionIndex = 0;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
