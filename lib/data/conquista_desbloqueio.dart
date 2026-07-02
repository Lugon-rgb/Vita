import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConquistaDesbloqueio {
  
  /// Função estática para desbloquear uma conquista e incrementar o XP do usuário.
  /// Pode ser chamada de qualquer tela do aplicativo.
  static Future<bool> desbloquear(String idDaConquista, int xpGanhado) async {
    final user = FirebaseAuth.instance.currentUser; // ve quem ta logado
    if (user == null) return false;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final conquistaDocRef = userDocRef.collection('conquistas').doc(idDaConquista);

    try {
      // checa se essa conquista ja existe pro usuário
      final docSnapshot = await conquistaDocRef.get();
      if (docSnapshot.exists) {
        return false; // se ja existe, para a execução aqui e retorna false (nao exibe SnackBar)
      }

      // se nao existia, cria o documento do desbloqueio
      await conquistaDocRef.set({'desbloqueado': true});

      // soma o xp no documento principal do usuário
      await userDocRef.update({
        'xp': FieldValue.increment(xpGanhado), // funcao do Firebase que altera o campo específico de forma segura
      });

      return true;
    } catch (e) {
      print('⚠️ Erro ao salvar conquista: $e');
      return false;
    }
  }

  // conta as notas ativas de cada categoria direto no servidor do Firebase.
  // se o usuário possuir pelo menos 2 de cada, libera a conquista 'mosaico_ideias'.
  static Future<String?> mosaicoIdeias() async {
    final user = FirebaseAuth.instance.currentUser; // ve quem ta logado
    if (user == null) return null;

    // pega a referencia do documento do usuario
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    // aponta para a subcolecao de notas dele (users -> id do usuario -> notas)
    final notasRef = userDocRef.collection('notas');

    try {
      // pede pro Firebase contar direto no servidor quantas notas ativas existem de cada categoria
      final cat1 = await notasRef.where('categoria', isEqualTo: 'Saúde').count().get();
      final cat2 = await notasRef.where('categoria', isEqualTo: 'Estudos').count().get();
      final cat3 = await notasRef.where('categoria', isEqualTo: 'Pessoal').count().get();
      final cat4 = await notasRef.where('categoria', isEqualTo: 'Finanças').count().get();

      // se todas as categorias tiverem 2 ou mais notas criadas no momento...
      if (cat1.count! >= 2 && cat2.count! >= 2 && cat3.count! >= 2 && cat4.count! >= 2) {
        // ...chama a função de cima para registrar o desbloqueio no banco e dar o xp
        final bool acoubouDeGanhar = await desbloquear('mosaico_ideias', 150);

        if (acoubouDeGanhar) {
          return 'Mosaico de Ideias.';
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Mosaico de Ideias: $e");
      return null;
    }
  }
}