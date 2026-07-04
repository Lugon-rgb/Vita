import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConquistaDesbloqueio {
  
  // funcao estatica para desbloquear uma conquista e incrementar o XP do usuario.
  // pode ser chamada de qualquer tela do aplicativo.
  static Future<bool> desbloquear(String idDaConquista, int xpGanhado) async {
    final user = FirebaseAuth.instance.currentUser; // ve quem ta logado
    if (user == null) return false;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final conquistaDocRef = userDocRef.collection('conquistas').doc(idDaConquista);

    try {
      // checa se essa conquista ja existe pro usuário
      final docSnapshot = await conquistaDocRef.get();
      if (docSnapshot.exists) {
        return false; // se ja existe, para a execução aqui e retorna false (nao exibe snackBar)
      }

      // se nao existia, cria o documento do desbloqueio
      await conquistaDocRef.set({'desbloqueado': true});

      // soma o xp no documento principal do usuario
      await userDocRef.update({
        'xp': FieldValue.increment(xpGanhado), // funcao do firebase que altera o campo especifico de forma segura
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

  // funcao da checagem de streak p desbloquear 3 conquistas diferentes
  static Future<List<String>> checarConquistasDeStreak(int diasDeStreak) async {
    List<String> conquistadasAgora = [];

    if (diasDeStreak >= 7) {
      bool ganhou = await ConquistaDesbloqueio.desbloquear('ritmo_semanal', 150);
      if (ganhou) conquistadasAgora.add('ritmo_semanal');
    }
    
    if (diasDeStreak >= 30) {
      bool ganhou = await ConquistaDesbloqueio.desbloquear('sequencia_guerreiro', 500);
      if (ganhou) conquistadasAgora.add('sequencia_guerreiro');
    }
    
    if (diasDeStreak >= 100) {
      bool ganhou = await ConquistaDesbloqueio.desbloquear('eternidade_vita', 5000);
      if (ganhou) conquistadasAgora.add('eternidade_vita');
    }
    
    return conquistadasAgora;
  }


  // verifica e libera a conquista registro_de_ouro
  static Future<String?> checarRegistroDeOuro() async {
    try {
      // chama a função centralizada que ja valida se existe e da o XP
      bool ganhou = await ConquistaDesbloqueio.desbloquear('registro_ouro', 50); 
      
      if (ganhou) {
        return 'registro_ouro'; // retorna o ID pro snackbar usar
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Registro de Ouro: $e");
      return null;
    }
  }

  // verifica e libera a conquista pilar_financas
  static Future<String?> checarPilarFinancas() async {
    try {
      // chama a funcao central que valida o banco e da o XP 
      bool ganhou = await ConquistaDesbloqueio.desbloquear('pilar_financas', 50);
      
      if (ganhou) {
        return 'pilar_financas'; // retorna o ID pro snackBar
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Pilar das Finanças: $e");
      return null;
    }
  }


  // verifica e libera a conquista de registrar gastos por 7 dias consecutivos
  static Future<String?> checarDisciplinaFinanceira(List<Map<String, dynamic>> listaGastos) async {
    try {
      // extrai apenas as datas (ano, mes, dia) e remove duplicadas do mesmo dia
      final datasUnicas = listaGastos.map((gasto) {
        final date = (gasto['data'] as Timestamp).toDate();
        return DateTime(date.year, date.month, date.day);
      }).toSet().toList();

      // ordena as datas da mais antiga para a mais recente
      datasUnicas.sort((a, b) => a.compareTo(b));

      int sequenciaAtual = 0;
      int maiorSequencia = 0;
      DateTime? dataAnterior;

      // varre as datas procurando dias consecutivos
      for (var data in datasUnicas) {
        if (dataAnterior == null) {
          sequenciaAtual = 1;
        } else {
          // calcula a diferenca em dias entre a data atual e a anterior
          final diferenca = data.difference(dataAnterior).inDays;
          
          if (diferenca == 1) {
            sequenciaAtual++; // dias consecutivos, incrementa a sequencia
          } else if (diferenca > 1) {
            sequenciaAtual = 1; // quebrou a sequência, recomeça do 1
          }
        }
        
        if (sequenciaAtual > maiorSequencia) {
          maiorSequencia = sequenciaAtual;
        }
        
        dataAnterior = data;
      }

      // se a maior sequência atingir 7 dias, tenta desbloquear a conquista
      if (maiorSequencia >= 7) {
        bool ganhou = await ConquistaDesbloqueio.desbloquear('disciplina_financeira', 150); //
        if (ganhou) {
          return 'disciplina_financeira';
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Disciplina Financeira: $e");
      return null;
    }
  }
}
