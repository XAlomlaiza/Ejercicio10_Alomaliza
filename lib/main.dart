import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculadoraFraccion());
}

class CalculadoraFraccion extends StatefulWidget {
  @override
  _CalculadoraFraccionState createState() => _CalculadoraFraccionState();
}

class _CalculadoraFraccionState extends State<CalculadoraFraccion> {
  TextEditingController _controller = TextEditingController();
  String _resultadoFraccion = '';
  String _resultadoDecimal = '';
  String _errorMensaje = ''; // variable para almacenar el mensaje de error

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ejercicio 10.- Calculadora de Fracciones'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Ingrese las fracciones separadas por + o - Ej. 5/2+1/4-2/6',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _calcular,
                child: Text('CALCULAR'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Resultado en fracción: $_resultadoFraccion',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Resultado simplificado: $_resultadoDecimal',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0), // Espacio entre los resultados y el mensaje de error
              Text(
                _errorMensaje, // Mostrar el mensaje de error aquí
                style: TextStyle(fontSize: 18.0, color: Colors.red), // Estilo para el mensaje de error
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calcular() {
    String input = _controller.text;
    input = input.replaceAll(' ', ''); // Eliminar espacios en blanco
    _errorMensaje = ''; // Limpiar el mensaje de error antes de calcular

    try {
      Parser p = Parser();
      ContextModel cm = ContextModel();

      Expression exp = p.parse(input);
      double resultDecimal = exp.evaluate(EvaluationType.REAL, cm);

      // Convertir el resultado decimal en fracción
      Fraction resultFraction = Fraction.convertirDobleFraccion(resultDecimal);

      // Simplificar la fracción
      resultFraction = fraccionSimplificada(resultFraction);

      setState(() {
        _resultadoFraccion = resultFraction.toString();
        _resultadoDecimal = resultDecimal.toStringAsFixed(2);
      });
    } catch (e) {
      // Mostrar un mensaje de advertencia en caso de error
      setState(() {
        _errorMensaje = 'Ingrese fracciones válidas por favor.';
      });
    }
  }

  // Función para simplificar una fracción
  Fraction fraccionSimplificada(Fraction fraction) {
    int mcd = _minimoComunDivisor(fraction.numerador, fraction.denominador);
    int numerador = fraction.numerador ~/ mcd;
    int denominador = fraction.denominador ~/ mcd;
    return Fraction(numerador, denominador);
  }

  static int _minimoComunDivisor(int a, int b) {
    while (b != 0) {
      var t = b;
      b = a % b;
      a = t;
    }
    return a.abs();
  }
}

class Fraction {
  int numerador;
  int denominador;

  Fraction(this.numerador, this.denominador);

  @override
  String toString() {
    if (denominador == 1) {
      return numerador.toString();
    } else {
      return '$numerador/$denominador';
    }
  }

  static Fraction convertirDobleFraccion(double valor) {
    // Convertir el valor decimal a una fracción
    int finalTodo = valor.floor();
    double remainder = valor - finalTodo;

    const double epsilon = 1.0E-10;
    double x = remainder;
    double numerador = 0;
    double denominadorInferior = 1;
    double denominador = 1;
    double DenominadorAlto = 1;
    double mitadNumerador = 0;
    double mitadDeniminador = 0;

    int maxIntentos = 1000; // Establecer un límite máximo de iteraciones
    int intentos = 0;

    while (intentos < maxIntentos) { // Asegurar que no se ejecute indefinidamente
      intentos++;
      mitadNumerador = numerador + denominador;
      mitadDeniminador = denominadorInferior + DenominadorAlto;
      if (mitadDeniminador * (x + epsilon) < mitadNumerador) {
        denominador = mitadNumerador;
        DenominadorAlto = mitadDeniminador;
      } else if (mitadDeniminador * (x - epsilon) > mitadNumerador) {
        numerador = mitadNumerador;
        denominadorInferior = mitadDeniminador;
      } else {
        return Fraction((finalTodo * mitadDeniminador + mitadNumerador).toInt(),
            mitadDeniminador.toInt());
      }
    }
    // Se devuelve el valor aproximado
    return Fraction(finalTodo, 1);
  }
}
