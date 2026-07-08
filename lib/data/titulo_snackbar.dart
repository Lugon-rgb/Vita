import 'package:flutter/material.dart';
import 'package:vita_appprojetos/data/dicionario_titulos.dart';

void mostrarSnackBarTitulo(BuildContext context, String idTitulo) {
  final titulo = listaDeTitulosDoApp.firstWhere(
    (t) => t.id == idTitulo,
    orElse: () => listaDeTitulosDoApp.first,
  );

  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF1E1E1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: titulo.corRaridade, width: 1.5),
      ),
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          const Text("🎖️", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TÍTULO DESBLOQUEADO!",
                  style: TextStyle(
                    color: titulo.corRaridade,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  titulo.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}