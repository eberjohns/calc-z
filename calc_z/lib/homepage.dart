import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Widget buildButton({required String label, bool isOperator = false}) {
    return SizedBox(
      // width: 100,
      // height: 100,
      child: ElevatedButton(
        onPressed: () {},
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
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomRight,
      child: Text(
        '0',
        style: TextStyle(
          color: Colors.white,
          fontSize: 50,
          fontWeight: FontWeight.bold,
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
            display(),
            makeRow(buttonLabels: ['C', '⌫', '%', '÷']),
            makeRow(buttonLabels: ['7', '8', '9', '×']),
            makeRow(buttonLabels: ['4', '5', '6', '−']),
            makeRow(buttonLabels: ['1', '2', '3', '+']),
            makeRow(buttonLabels: ['^', '0', '.', '=']),
            SizedBox(height: 10), // Add some space at the bottom
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
