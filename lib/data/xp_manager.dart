import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'titulo_desbloqueio.dart';

class GerenciadorXp {
  static const int xpBase = 500;
  static const int incrementoPorNivel = 100;

  static int limiarDoNivel(int nivel) {
    return xpBase + (nivel - 1) * incrementoPorNivel;
  }

  static Future<void> adicionarXp(int xpGanhado) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    // a transacao agora retorna o nivel final, pra podermos checar titulos
    // de nivel logo depois, ja fora da transacao
    final novoNivel = await FirebaseFirestore.instance.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(userDocRef);
      final data = snapshot.data() ?? {};

      int xpAtual = (data['xp'] ?? 0) as int;
      int nivelAtual = (data['nivel'] ?? 1) as int;

      xpAtual += xpGanhado;

      while (xpAtual >= limiarDoNivel(nivelAtual)) {
        xpAtual -= limiarDoNivel(nivelAtual);
        nivelAtual++;
      }

      transaction.set(userDocRef, {
        'xp': xpAtual,
        'nivel': nivelAtual,
      }, SetOptions(merge: true));

      return nivelAtual;
    });

    // verifica se o nivel atingido libera algum titulo
    await TituloDesbloqueio.checarTitulosDeNivel(novoNivel);
  }
}