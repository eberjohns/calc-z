import 'dart:math';

import 'package:flutter/material.dart';

String _displayText = '';
String _resultText = '';
String _userVisibleText = '';

String get displayText => _displayText;
String get resultText => _resultText;
String get userVisibleText => _userVisibleText;

int precedence(String op) {
  if (op == '+' || op == '-') return 1;
  if (op == '*' || op == '/' || op == '%') return 2;
  if (op == '^') return 3;
  // For exponentiation if you add it, it would be higher, e.g., if (op == '^') return 3;
  return 0; // For parentheses or unknown
}

// Converts an infix expression to a postfix expression
String infixToPostfix(String infix) {
  String postfixResult = '';
  List<String> operators = [];

  int i = 0;
  while (i < infix.length) {
    String ch = infix[i];

    if (_isDigit(ch)) {
      String numStr = '';
      while (i < infix.length && _isDigit(infix[i])) {
        numStr += infix[i];
        i++;
      }
      postfixResult += '$numStr ';
      continue; // Don't increment i again
    } else if (ch == '(') {
      operators.add(ch);
    } else if (ch == ')') {
      while (operators.isNotEmpty && operators.last != '(') {
        postfixResult += '${operators.removeLast()} ';
      }
      if (operators.isNotEmpty && operators.last == '(') {
        operators.removeLast();
      } else {
        throw Exception('Mismatched parentheses');
      }
    } else if (_isOperator(ch)) {
      while (operators.isNotEmpty &&
          precedence(ch) < precedence(operators.last)) {
        postfixResult += '${operators.removeLast()} ';
      }
      operators.add(ch);
    }
    i++; // Move to next character
  }

  while (operators.isNotEmpty) {
    postfixResult += '${operators.removeLast()} ';
  }

  if (postfixResult.endsWith(' ')) {
    postfixResult = postfixResult.trim();
  }

  return postfixResult;
}

double evaluatePostfix(String postfix) {
  List<double> values = [];
  List<String> tokens = postfix.split(' ');

  for (String token in tokens) {
    if (_isOperator(token)) {
      if (values.length < 2) {
        throw Exception('Invalid postfix: not enough operands.');
      }
      double val2 = values.removeLast();
      double val1 = values.removeLast();

      switch (token) {
        case '+':
          values.add(val1 + val2);
          break;
        case '-':
          values.add(val1 - val2);
          break;
        case '*':
          values.add(val1 * val2);
          break;
        case '%':
          if (val2 == 0) throw Exception('Modulus by zero');
          values.add((val1 % val2).toDouble());
          break;
        case '^':
          values.add(pow(val1, val2).toDouble());
          break;
        case '/':
          if (val2 == 0) throw Exception('Division by zero');
          values.add((val1 / val2));
          break;
        default:
          throw Exception('Unknown operator: $token');
      }
    } else {
      values.add(double.parse(token));
    }
  }

  if (values.length != 1) {
    throw Exception('Invalid postfix expression');
  }

  return values.last;
}

// Helper to check if a character is a digit
bool _isDigit(String ch) {
  return ch.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
      ch.codeUnitAt(0) <= '9'.codeUnitAt(0);
}

// Helper to check if a character is an operator
bool _isOperator(String ch) {
  return ch == '+' ||
      ch == '-' ||
      ch == '*' ||
      ch == '/' ||
      ch == '^' ||
      ch == '%';
}

void clear() {
  _displayText = '';
  _userVisibleText = '';
  _resultText = '';
}

void backspace() {
  if (_displayText.isNotEmpty) {
    _displayText = _displayText.substring(0, _displayText.length - 1);
    _userVisibleText = _userVisibleText.substring(
      0,
      _userVisibleText.length - 1,
    );
  }
}

void append(String logicChar, [String? visibleChar]) {
  _displayText += logicChar;
  _userVisibleText += visibleChar ?? logicChar;
}

void calculate() {
  try {
    String postfix = infixToPostfix(_displayText);
    _resultText = evaluatePostfix(postfix).toString();
  } catch (e) {
    _resultText = 'Error';
    print('Calculation error: $e');
  }
}

void setDisplayText(String text) {
  _userVisibleText = text;
}

void setResultText(String text) {
  _resultText = text;
}
