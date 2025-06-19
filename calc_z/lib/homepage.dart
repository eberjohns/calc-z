import 'package:calc_z/logic.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  void changeDisplayText(String text) {
    if (text == 'C') {
      clear();
    } else if (text == '⌫') {
      backspace();
    } else if (text == '=') {
      calculate();
    } else {
      switch (text) {
        case '÷':
          append('/', '÷');
          break;
        case '×':
          append('*', '×');
          break;
        case '−':
          append('-', '−');
          break;
        case '^':
          append('^', '^');
          break;
        case '%':
          append('%', '%');
          break;
        default:
          append(text); // uses same logic & visible character
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
              label == 'C' ||
              label == '⌫' ||
              label == '÷' ||
              label == '×' ||
              label == '−' ||
              label == '+' ||
              label == '^' ||
              label == '%' ||
              label == '=',
        );
      }).toList(),
    );
  }

  Widget display() {
    return Container(
      color: const Color.fromARGB(255, 15, 15, 15),
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

  Widget buildHomePage() {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          'Calc-Z',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(flex: 8, child: display()),
            Expanded(
              flex: 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  makeRow(buttonLabels: ['C', '⌫', '%', '÷']),
                  makeRow(buttonLabels: ['7', '8', '9', '×']),
                  makeRow(buttonLabels: ['4', '5', '6', '−']),
                  makeRow(buttonLabels: ['1', '2', '3', '+']),
                  makeRow(buttonLabels: ['^', '0', '.', '=']),
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
