import 'dart:math';

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

    // Check if the character is a digit or a decimal point
    if (_isDigit(ch) || ch == '.') {
      String numStr = '';
      bool hasDecimal = false;

      // Handle numbers starting with a decimal point, e.g., ".5"
      if (ch == '.') {
        numStr = '0.';
        hasDecimal = true;
        i++;
      }

      // Read the rest of the number (digits and a single decimal point)
      while (i < infix.length) {
        String currentChar = infix[i];
        if (_isDigit(currentChar)) {
          numStr += currentChar;
        } else if (currentChar == '.' && !hasDecimal) {
          numStr += currentChar;
          hasDecimal = true;
        } else {
          // Break if it's not a digit or it's a second decimal point
          break;
        }
        i++;
      }

      postfixResult += '$numStr ';
      continue; // Skip the i++ at the end of the main loop
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
          operators.last != '(' &&
          precedence(ch) <= precedence(operators.last)) {
        postfixResult += '${operators.removeLast()} ';
      }
      operators.add(ch);
    }
    i++; // Move to next character
  }

  while (operators.isNotEmpty) {
    if (operators.last == '(') {
      throw Exception('Mismatched parentheses');
    }
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
      ch == '%'; // ||
  // ch == '(' ||
  // ch == ')';
}

// Helper to check if the last character is an operator
bool checkLastIsOperator() {
  if (_displayText.isEmpty) {
    return false; // No characters to check
  }

  String lastChar = _displayText[_displayText.length - 1];
  return _isOperator(lastChar);
}

// Helper to get the current number segment being typed
String getCurrentNumberSegment() {
  if (_displayText.isEmpty) {
    return '';
  }

  // Find the last operator or opening/closing parenthesis index
  int lastBreakIndex = -1;
  for (int i = _displayText.length - 1; i >= 0; i--) {
    String char = _displayText[i];
    if (_isOperator(char) || char == '(' || char == ')') {
      lastBreakIndex = i;
      break;
    }
  }

  // The current number segment is from the last break point + 1 to the end
  return _displayText.substring(lastBreakIndex + 1);
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
  // If the display is empty, do nothing.
  if (_displayText.isEmpty) {
    _resultText = '';
    return;
  }

  // Create a temporary expression to evaluate.
  String tempExpression = _displayText;

  // Trim trailing operators to evaluate the last valid number or sub-expression (e.g., "12+" becomes "12").
  if (tempExpression.isNotEmpty) {
    String lastChar = tempExpression.substring(tempExpression.length - 1);
    while (_isOperator(lastChar)) {
      tempExpression = tempExpression.substring(0, tempExpression.length - 1);
      if (tempExpression.isEmpty) {
        _resultText = '';
        return;
      }
      lastChar = tempExpression.substring(tempExpression.length - 1);
    }
  }

  // --- NEW LOGIC FOR PARENTHESES ---
  // Count unmatched opening parentheses to add them for temporary calculation.
  int openParentheses = 0;
  int closeParentheses = 0;
  for (int i = 0; i < tempExpression.length; i++) {
    if (tempExpression[i] == '(') {
      openParentheses++;
    } else if (tempExpression[i] == ')') {
      closeParentheses++;
    }
  }

  // If there are unmatched opening parentheses, close them for temporary calculation.
  int missingParentheses = openParentheses - closeParentheses;
  if (missingParentheses > 0) {
    tempExpression += ')' * missingParentheses;
  } else if (missingParentheses < 0) {
    // If there are unmatched closing parentheses, the expression is invalid.
    _resultText = '';
    return;
  }
  // --- END OF NEW LOGIC ---

  try {
    // Now, attempt to calculate the cleaned-up temporary expression.
    String postfix = infixToPostfix(tempExpression);
    _resultText = evaluatePostfix(postfix).toString();
  } catch (e) {
    // If the calculation still fails (e.g., division by zero, invalid characters), clear the result.
    _resultText = '';
    print('Calculation error on temp expression: $e');
  }
}

void setDisplayText(String text) {
  _userVisibleText = text;
}

void setResultText(String text) {
  _resultText = text;
}
