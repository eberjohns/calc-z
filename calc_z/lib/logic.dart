import 'dart:math';

String _displayText = '';
String _resultText = '';
String _userVisibleText = '';

// Global storage for user-defined scalar variables
// Key: variable name (e.g., 'a', 'b', 'c'), Value: its current numeric value
Map<String, double> globalScalarVariables = {};

// Helper to get the next available single-letter variable name (a, b, c, ...)
String getNextScalarVariableName() {
  for (int i = 0; i < 26; i++) {
    // Limited to 26 variables (a-z)
    String varName = String.fromCharCode('a'.codeUnitAt(0) + i);
    if (!globalScalarVariables.containsKey(varName)) {
      return varName;
    }
  }
  throw Exception('No more available scalar variable names (a-z).');
}

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
    } else if (ch.length == 1 &&
        ch.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
        ch.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
      postfixResult += '$ch '; // Add the variable name as a token
      i++; // Move to the next character
      continue; // Continue to the next iteration of the while loop
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
      // If the token is not an operator
      double? parsedValue = double.tryParse(token); // Try parsing as a number

      if (parsedValue != null) {
        values.add(parsedValue); // If it's a number, push it onto the stack
      }
      // --- Check if the token is a defined scalar variable ('a' through 'z') ---
      else if (token.length == 1 &&
          token.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          token.codeUnitAt(0) <= 'z'.codeUnitAt(0) &&
          globalScalarVariables.containsKey(token)) {
        // If it's a valid single-letter variable and it's in our global map,
        // push its stored value onto the stack.
        values.add(
          globalScalarVariables[token]!,
        ); // '!' asserts non-null because we just checked containsKey
      } else {
        // If it's neither an operator, a number, nor a recognized variable, throw an error.
        throw Exception('Invalid operand or undefined variable: "$token"');
      }
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

bool checkLastIsNumberOrVariable() {
  if (_displayText.isEmpty) {
    return false; // No characters to check
  }

  String lastChar = _displayText[_displayText.length - 1];
  return _isDigit(lastChar) ||
      (lastChar.length == 1 &&
          lastChar.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          lastChar.codeUnitAt(0) <= 'z'.codeUnitAt(0));
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

// void handleVarButtonPress() {
//   try {
//     // If this is a truly new variable being defined for the first time, initialize its value to 0.0
//     if (!globalScalarVariables.containsKey(newVarName)) {
//       globalScalarVariables[newVarName] = 0.0; // Initialize with value 0
//     }
//   } catch (e) {
//     print('Error: $e'); // All var names a-z are used
//     // Optionally, you could show a small toast or message to the user here
//     // that no more variables are available.
//     return; // Stop if no more variables are available
//   }

//   // --- Pre-append logic (auto-multiplication) ---
//   // If the last character in the visible display is a digit or closing parenthesis,
//   // implicitly add a multiplication operator, as implied by calculator behavior (e.g., 5a should be 5*a).
//   if (userVisibleText.isNotEmpty) {
//     String lastChar = userVisibleText.substring(userVisibleText.length - 1);
//     if (_isDigit(lastChar) || lastChar == ')') {
//       // _isDigit is local helper
//       append('*', '×'); // Append multiplication operator (internal and visible)
//     }
//   }
//   // --- End Pre-append logic ---

//   append(varToInsert); // Append the chosen variable name (e.g., 'a') to display
//   calculate(); // Recalculate
// }

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

// ... (keep all your existing code above calculate() in logic.dart) ...

void calculate() {
  // If the display is empty, clear the result and return.
  if (_displayText.isEmpty) {
    _resultText = '';
    return;
  }

  // Create a temporary expression to work with for evaluation.
  String tempExpression = _displayText;

  // Trim trailing operators to allow partial expressions to evaluate (e.g., "12+" evaluates "12").
  if (tempExpression.isNotEmpty) {
    String lastChar = tempExpression.substring(tempExpression.length - 1);
    while (_isOperator(lastChar)) {
      // _isOperator is already defined in logic.dart
      tempExpression = tempExpression.substring(0, tempExpression.length - 1);
      if (tempExpression.isEmpty) {
        _resultText = '';
        return;
      }
      lastChar = tempExpression.substring(tempExpression.length - 1);
    }
  }

  // Auto-close any unclosed opening parentheses for temporary calculation.
  int openParentheses = 0;
  int closeParentheses = 0;
  for (int i = 0; i < tempExpression.length; i++) {
    if (tempExpression[i] == '(') {
      openParentheses++;
    } else if (tempExpression[i] == ')') {
      closeParentheses++;
    }
  }

  int missingParentheses = openParentheses - closeParentheses;
  if (missingParentheses > 0) {
    tempExpression += ')' * missingParentheses; // Append missing ')'
  } else if (missingParentheses < 0) {
    // If there are more closing parentheses than opening, it's an invalid expression.
    _resultText = ''; // Clear result for invalid parenthesis structure.
    return;
  }

  try {
    // Now, attempt to calculate the cleaned-up temporary expression.
    String postfix = infixToPostfix(tempExpression);
    double calculatedResult = evaluatePostfix(postfix);

    // --- NEW LOGIC FOR TRUNCATING .0 ---
    // Check if the number is a whole number (e.g., 3.0)
    if (calculatedResult == calculatedResult.roundToDouble()) {
      // or calculatedResult == calculatedResult.toInt().toDouble()
      // If it's a whole number, convert it to an integer and then to a string
      _resultText = calculatedResult.round().toString();
    } else {
      // Otherwise, keep the decimal places
      _resultText = calculatedResult.toString();
    }
    // --- END NEW LOGIC ---
  } catch (e) {
    // If any error occurs during calculation, clear the result display to avoid showing "Error" during typing of an incomplete or invalid expression.
    _resultText = '';
    print(
      'Calculation error on temp expression: $e',
    ); // Print error to console for debugging.
  }
}

void setDisplayText(String text) {
  _userVisibleText = text;
}

void setResultText(String text) {
  _resultText = text;
}
