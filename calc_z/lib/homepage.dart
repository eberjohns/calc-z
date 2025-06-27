import 'package:calc_z/logic.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String?
  _selectedVarForOptions; // Stores the name of the variable whose options are currently visible. Null if none.

  void handleVarButtonPress() {
    try {
      String newVarName =
          getNextScalarVariableName(); // Get 'a', 'b', 'c', etc.
      if (!globalScalarVariables.containsKey(newVarName)) {
        globalScalarVariables[newVarName] = 0.0; // Initialize with value 0
      }
      // No longer appending to main display or opening dialog automatically here.
      // We just ensure the variable exists and its tag will appear.
      setState(() {
        // Trigger rebuild to show the new variable tag
        _selectedVarForOptions = newVarName; // Auto-select the newly added var
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Variable "$newVarName" added with value 0.')),
      );
    } catch (e) {
      print('Error adding new variable: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more variable names available (a-z)!'),
        ),
      );
    }
  }

  void changeDisplayText(String text) {
    // if (text == 'C') {
    //   clear();
    // } else
    if (text == '⌫') {
      backspace();
      calculate();
      // } else if (text == '=') {
      //   calculate();
    } else if (text == 'VAR_ACTION') {
      if (!checkLastIsNumberOrVariable()) {
        handleVarButtonPress();
      }
    } else {
      switch (text) {
        case '÷':
          if (checkLastIsOperator()) backspace();
          append('/', '÷');
          break;
        case '×':
          if (checkLastIsOperator()) backspace();
          append('*', '×');
          break;
        case '−':
          if (checkLastIsOperator()) backspace();
          append('-', '−');
          break;
        case '^':
          if (checkLastIsOperator()) backspace();
          append('^', '^');
          break;
        case '%':
          if (checkLastIsOperator()) backspace();
          append('%', '%');
          break;
        case '+':
          if (checkLastIsOperator()) backspace();
          append('+', '+');
          break;
        case '(':
          // if (checkLastIsOperator()) backspace();
          append('(', '(');
          break;
        case ')':
          // if (checkLastIsOperator()) backspace();
          append(')', ')');
          calculate();
          break;
        default:
          String currentNumber = getCurrentNumberSegment();
          // Count only actual digits (remove decimal point for length check)
          int digitCount = currentNumber.replaceAll('.', '').length;

          // If the current number already has 10 digits, prevent appending
          if (digitCount >= 10) {
            break; // Do nothing if limit reached
          }
          append(text); // Append the digit or other character
          calculate(); // Numbers always trigger recalculation
      }
    }
    setState(() {});
  }

  Widget buildButton({required String label, bool isOperator = false}) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: () {
          changeDisplayText(label);
        },
        onLongPress: () {
          if (label == '⌫') {
            clear();
            setState(() {});
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        child: Text(
          label,
          style: TextStyle(
            color: isOperator ? Colors.deepPurpleAccent : Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget makeRow({required List<String> buttonLabels}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: buttonLabels.map((label) {
        return buildButton(
          label: label,
          isOperator:
              // label == 'C' ||
              label == '⌫' ||
              label == '÷' ||
              label == '×' ||
              label == '−' ||
              label == '+' ||
              label == '^' ||
              label == '%' ||
              // label == '=' ||
              label == '(' ||
              label == ')',
        );
      }).toList(),
    );
  }

  Widget display() {
    return Container(
      color: Colors.grey[900], //const Color.fromARGB(255, 15, 15, 15),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomRight,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              // Display typed numbers
              userVisibleText != '' ? userVisibleText : '0',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget result() {
    return Container(
      color: Colors.grey[900], //const Color.fromARGB(255, 15, 15, 15),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomRight,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resultText != '' ? '= $resultText' : '',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color.fromARGB(202, 255, 255, 255),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showScalarVariableEditor(String varName) {
    TextEditingController controller = TextEditingController(
      text:
          globalScalarVariables[varName]?.toString() ??
          '0.0', // Display current value
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850], // Dark background for dialog
          title: Text(
            'Edit Variable: $varName',
            style: const TextStyle(color: Colors.white, fontFamily: 'Jaro'),
          ),
          content: TextField(
            controller: controller,
            keyboardType:
                TextInputType.number, // Allows numbers and decimal point
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Jaro',
              fontSize: 20,
            ),
            decoration: InputDecoration(
              labelText: 'Value',
              labelStyle: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Jaro',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepPurpleAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70, fontFamily: 'Jaro'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontFamily: 'Jaro',
                ),
              ),
              onPressed: () {
                double? newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  setState(() {
                    globalScalarVariables[varName] =
                        newValue; // Update the global value
                    calculate(); // Recalculate if this variable is in the expression
                  });
                } else {
                  // Show error for invalid input if necessary
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid number entered!')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- New: Widget to display and allow interaction with defined scalar variables ---
  Widget buildVariableTagsDisplay() {
    // if (globalScalarVariables.isEmpty) {
    //   return Container(
    //     height: 0,
    //   ); // Return empty container if no variables are defined, taking no space
    // }
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          // Use Wrap to allow names to flow onto new lines
          spacing: 8.0, // Horizontal spacing between variable tags
          runSpacing: 4.0, // Vertical spacing between lines of tags
          children: globalScalarVariables.keys.map((varName) {
            return InkWell(
              // Make each variable name tappable
              onTap: () => showScalarVariableEditor(
                varName,
              ), // Open editor for this variable
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[850], // Background color for the tag
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                  border: Border.all(width: 1.5), // Border for tags
                ),
                child: Text(
                  varName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Jaro',
                  ), // Apply Jaro font
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildHomePage() {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black, // Dark background matching your design
        elevation: 0, // No shadow for a flat look
        toolbarHeight: 60, // Standard app bar height

        title: Row(
          // Use a Row for "Calc-" and "Z"
          mainAxisSize: MainAxisSize.min, // Keep the row compact
          children: const [
            Text(
              'Calc-',
              style: TextStyle(
                color: Colors.white,
                fontSize: 55, // Slightly larger font for title
                fontWeight: FontWeight.bold,
                fontFamily: 'Jaro', // Apply Jaro font
              ),
            ),
            Text(
              'Z',
              style: TextStyle(
                color: Colors.deepPurpleAccent, // Purple for 'Z'
                fontSize: 60, // Match font size
                fontWeight: FontWeight.bold,
                fontFamily: 'Jaro', // Apply Jaro font
              ),
            ),
          ],
        ),
        actions: [
          // Add actions for VAR and MAT buttons
          TextButton(
            onPressed: () {
              changeDisplayText('VAR_ACTION');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white, // Match app bar background
              foregroundColor: Colors.black, // Black text
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jaro', // Apply Jaro font
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                // side: BorderSide(color: Colors.white), // Subtle border
              ),
            ),
            child: const Text('DAT', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 8), // Spacer between buttons
          TextButton(
            onPressed: () {
              print('MATRIX button pressed');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white, // Match app bar background
              foregroundColor: Colors.black, // Black text
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jaro', // Apply Jaro font
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                // side: BorderSide(color: Colors.white), // Subtle border
              ),
            ),
            child: const Text('MAT', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 8), // Padding on the right edge
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 1,
              child: buildVariableTagsDisplay(),
            ), // Display variable tags at the top
            Expanded(flex: 5, child: display()),
            Expanded(flex: 2, child: result()),
            Expanded(
              flex: 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  makeRow(buttonLabels: ['(', ')', '⌫', '%']),
                  makeRow(buttonLabels: ['7', '8', '9', '÷']),
                  makeRow(buttonLabels: ['4', '5', '6', '×']),
                  makeRow(buttonLabels: ['1', '2', '3', '−']),
                  makeRow(buttonLabels: ['^', '0', '.', '+']),
                ],
              ),
            ), // Add some space at the bottom
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: buildHomePage());
  }
}
