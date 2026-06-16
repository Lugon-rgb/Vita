import 'package:flutter/material.dart';

class TituloModelo {
  final String id;
  final String nome;
  final String descricao;
  final Color corRaridade;

  const TituloModelo({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.corRaridade,
  });
}