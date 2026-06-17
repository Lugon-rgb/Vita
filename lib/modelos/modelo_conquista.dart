import 'package:flutter/material.dart';

class ConquistaModelo {
  final String id;
  final String nome;
  final String descricao;
  final Color corRaridade;

  const ConquistaModelo ({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.corRaridade,
  });
}