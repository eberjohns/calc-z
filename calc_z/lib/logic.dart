import 'package:flutter/material.dart';

String _displayText = '';
String _resultText = '';

String get displayText => _displayText;
String get resultText => _resultText;

void clear() {
  _displayText = '';
  _resultText = '';
}

void backspace() {
  if (_displayText.isNotEmpty) {
    _displayText = _displayText.substring(0, _displayText.length - 1);
  }
}

void append(String text) {
  _displayText += text;
}

void calculate() {
  // Implement calculation logic here
  // For now, just set _resultText to _displayText
  _resultText = _displayText; // Placeholder for actual calculation
}

void setDisplayText(String text) {
  _displayText = text;
}

void setResultText(String text) {
  _resultText = text;
}
