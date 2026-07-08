import 'package:flutter/material.dart';

// pequena pausa entre um snackbar e outro, pra dar tempo do usuario ler antes
// do proximo aparecer (o mostrarSnackBarConquista/mostrarSnackBarTitulo
// removem o snackbar anterior na hora, entao sem essa pausa o penultimo nem
// chega a ser visto)
Future<void> esperarSnackbar() {
  return Future.delayed(const Duration(milliseconds: 4300));
}