
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(FractionCalculator());
}

class FractionCalculator extends StatefulWidget {
  @override
  _FractionCalculatorState createState() => _FractionCalculatorState();
}

class _FractionCalculatorState extends State<FractionCalculator> {
  TextEditingController _controller = TextEditingController();
  String _resultFraction = '';
  String _resultDecimal = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fraction Calculator'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Ingrese las fracciones separadas por + o -',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _calculate,
                child: Text('Calcular'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Resultado en fracción: $_resultFraction',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Resultado simplificado: $_resultDecimal',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
  String input = _controller.text;
  input = input.replaceAll(' ', ''); // Eliminar espacios en blanco

  // Reemplazar '-' con '-1*' para simplificar el análisis
  input = input.replaceAll('-', '-1*');

  try {
    Parser p = Parser();
    ContextModel cm = ContextModel();

    Expression exp = p.parse(input);
    double resultDecimal = exp.evaluate(EvaluationType.REAL, cm);

    // Convertir el resultado decimal en fracción
    Fraction resultFraction = Fraction.fromDouble(resultDecimal);

    // Simplificar la fracción
    resultFraction = simplifyFraction(resultFraction);

    setState(() {
      _resultFraction = resultFraction.toString();
      _resultDecimal = resultDecimal.toStringAsFixed(2);
    });
  } catch (e) {
    // Mostrar un mensaje de advertencia en la consola
    print('Ingrese fracciones válidas por favor.');
  }
}

  // Función para simplificar una fracción
  Fraction simplifyFraction(Fraction fraction) {
    int gcd = _gcd(fraction.numerator, fraction.denominator);
    int numerator = fraction.numerator ~/ gcd;
    int denominator = fraction.denominator ~/ gcd;
    return Fraction(numerator, denominator);
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      var t = b;
      b = a % b;
      a = t;
    }
    return a.abs();
  }
}

class Fraction {
  int numerator;
  int denominator;

  Fraction(this.numerator, this.denominator);

  @override
  String toString() {
    if (denominator == 1) {
      return numerator.toString();
    } else {
      return '$numerator/$denominator';
    }
  }

  static Fraction fromDouble(double value) {
    // Convertir el valor decimal a una fracción
    int whole = value.floor();
    double remainder = value - whole;

    const double epsilon = 1.0E-10;
    double x = remainder;
    double lowerNumerator = 0;
    double lowerDenominator = 1;
    double upperNumerator = 1;
    double upperDenominator = 1;
    double middleNumerator = 0;
    double middleDenominator = 0;

    while (true) {
      middleNumerator = lowerNumerator + upperNumerator;
      middleDenominator = lowerDenominator + upperDenominator;
      if (middleDenominator * (x + epsilon) < middleNumerator) {
        upperNumerator = middleNumerator;
        upperDenominator = middleDenominator;
      } else if (middleDenominator * (x - epsilon) > middleNumerator) {
        lowerNumerator = middleNumerator;
        lowerDenominator = middleDenominator;
      } else {
        return Fraction((whole * middleDenominator + middleNumerator).toInt(),
            middleDenominator.toInt());
      }
    }
  }
}

//C:\Users\DELL\AppData\Local\Android\Sdk\platform-tools
//.\adb connect localhost:5555
