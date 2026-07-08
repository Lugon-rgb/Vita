import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'xp_manager.dart';
import 'titulo_desbloqueio.dart';

class ConquistaDesbloqueio {
  // funcao estatica para desbloquear uma conquista e incrementar o XP do usuario.
  // pode ser chamada de qualquer tela do aplicativo.
  static Future<bool> desbloquear(String idDaConquista, int xpGanhado) async {
    final user = FirebaseAuth.instance.currentUser; // ve quem ta logado
    if (user == null) return false;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final conquistaDocRef = userDocRef
        .collection('conquistas')
        .doc(idDaConquista);

    try {
      // checa se essa conquista ja existe pro usuário
      final docSnapshot = await conquistaDocRef.get();
      if (docSnapshot.exists) {
        return false; // se ja existe, para a execução aqui e retorna false (nao exibe SnackBar)
      }

      // se nao existia, cria o documento do desbloqueio
      await conquistaDocRef.set({'desbloqueado': true});

      // soma o xp no documento principal do usuario, ja respeitando a regra
      // de subida de nivel (a cada 500 xp) de forma atomica
      await GerenciadorXp.adicionarXp(xpGanhado);

      // verifica se essa conquista libera algum titulo (simples ou combo)
      await TituloDesbloqueio.checarTituloPorConquista(idDaConquista);

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
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    // aponta para a subcolecao de notas dele (users -> id do usuario -> notas)
    final notasRef = userDocRef.collection('notas');

    try {
      // pede pro Firebase contar direto no servidor quantas notas ativas existem de cada categoria
      final cat1 = await notasRef
          .where('categoria', isEqualTo: 'Saúde')
          .count()
          .get();
      final cat2 = await notasRef
          .where('categoria', isEqualTo: 'Estudos')
          .count()
          .get();
      final cat3 = await notasRef
          .where('categoria', isEqualTo: 'Pessoal')
          .count()
          .get();
      final cat4 = await notasRef
          .where('categoria', isEqualTo: 'Finanças')
          .count()
          .get();

      // se todas as categorias tiverem 2 ou mais notas criadas no momento...
      if (cat1.count! >= 2 &&
          cat2.count! >= 2 &&
          cat3.count! >= 2 &&
          cat4.count! >= 2) {
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
      bool ganhou = await ConquistaDesbloqueio.desbloquear(
        'ritmo_semanal',
        150,
      );
      if (ganhou) conquistadasAgora.add('ritmo_semanal');
    }

    if (diasDeStreak >= 30) {
      bool ganhou = await ConquistaDesbloqueio.desbloquear(
        'sequencia_guerreiro',
        500,
      );
      if (ganhou) conquistadasAgora.add('sequencia_guerreiro');
    }

    if (diasDeStreak >= 100) {
      bool ganhou = await ConquistaDesbloqueio.desbloquear(
        'eternidade_vita',
        5000,
      );
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
      bool ganhou = await ConquistaDesbloqueio.desbloquear(
        'pilar_financas',
        50,
      );

      if (ganhou) {
        return 'pilar_financas'; // retorna o ID pro snackBar
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Pilar das Finanças: $e");
      return null;
    }
  }

  // verifica e libera a conquista primeira_vitoria
  static Future<String?> checarPrimeiraVitoria() async {
    try {
      // chama a funcao central que ja garante que so desbloqueia uma vez
      bool ganhou = await ConquistaDesbloqueio.desbloquear(
        'primeira_vitoria',
        50,
      );

      if (ganhou) {
        return 'primeira_vitoria'; // retorna o ID pro snackbar usar
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Primeira Vitória: $e");
      return null;
    }
  }

  // verifica quantas metas de curto prazo o usuario ja concluiu no total.
  // se atingir 5, libera a conquista 'serie_triunfos'.
  static Future<String?> checarSerieTriunfos() async {
    final user = FirebaseAuth.instance.currentUser; // ve quem ta logado
    if (user == null) return null;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final goalsRef = userDocRef.collection('goals');

    try {
      // pede pro Firebase contar direto no servidor quantas metas de curto prazo
      // ja concluidas (progress == 1) existem
      final contagem = await goalsRef
          .where('period', isEqualTo: 'Curto Prazo')
          .where('progress', isEqualTo: 1.0)
          .count()
          .get();

      if (contagem.count! >= 5) {
        bool ganhou = await ConquistaDesbloqueio.desbloquear(
          'serie_triunfos',
          150,
        );
        if (ganhou) {
          return 'serie_triunfos';
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Série de Triunfos: $e");
      return null;
    }
  }

  // verifica quantas metas de longo prazo o usuario ja concluiu no total.
  // se atingir 6, libera a conquista 'caminho_estruturado'.
  static Future<String?> checarCaminhoEstruturado() async {
    final user = FirebaseAuth.instance.currentUser; // ve quem ta logado
    if (user == null) return null;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final goalsRef = userDocRef.collection('goals');

    try {
      // pede pro Firebase contar direto no servidor quantas metas de longo prazo
      // ja concluidas (progress == 1) existem
      final contagem = await goalsRef
          .where('period', isEqualTo: 'Longo Prazo')
          .where('progress', isEqualTo: 1.0)
          .count()
          .get();

      if (contagem.count! >= 6) {
        bool ganhou = await ConquistaDesbloqueio.desbloquear(
          'caminho_estruturado',
          1000,
        );
        if (ganhou) {
          return 'caminho_estruturado';
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista Caminho Estruturado: $e");
      return null;
    }
  }

  // verifica se uma meta de curto prazo foi concluida em menos de 24h apos ser criada
  static Future<String?> checarMenteAgil(DateTime? criadoEm) async {
    if (criadoEm == null) return null; // metas antigas, criadas antes dessa feature, nao tem essa data

    final diferenca = DateTime.now().difference(criadoEm);

    if (diferenca.inHours < 24) {
      bool ganhou = await ConquistaDesbloqueio.desbloquear('mente_agil', 50);
      if (ganhou) {
        return 'mente_agil';
      }
    }
    return null;
  }

  // funcao generica e privada: verifica se existem 3 metas concluidas de uma
  // categoria dentro de uma janela de 7 dias. usada pelas conquistas
  // 'sede_conhecimento' (Estudos) e 'elixir_vida' (Saúde).
  static Future<String?> _checarConclusoesEmUmaSemana({
    required String categoria,
    required String idConquista,
    required int xpGanhado,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final goalsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('goals');

    try {
      final snapshot = await goalsRef
          .where('category', isEqualTo: categoria)
          .where('progress', isEqualTo: 1.0)
          .get();

      final datasConclusao = snapshot.docs
          .map((doc) => (doc.data()['concluidoEm'] as Timestamp?)?.toDate())
          .whereType<DateTime>()
          .toList()
        ..sort();

      if (datasConclusao.length < 3) return null;

      for (int i = 0; i <= datasConclusao.length - 3; i++) {
        final diferenca = datasConclusao[i + 2].difference(datasConclusao[i]);
        if (diferenca.inDays <= 7) {
          bool ganhou = await desbloquear(idConquista, xpGanhado);
          if (ganhou) return idConquista;
          return null;
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Erro na checagem da conquista $idConquista: $e");
      return null;
    }
  }

  // verifica e libera a conquista sede_conhecimento (categoria Estudos)
  static Future<String?> checarSedeConhecimento() {
    return _checarConclusoesEmUmaSemana(
      categoria: 'Estudos',
      idConquista: 'sede_conhecimento',
      xpGanhado: 150,
    );
  }

  // verifica e libera a conquista elixir_vida (categoria Saúde)
  static Future<String?> checarElixirVida() {
    return _checarConclusoesEmUmaSemana(
      categoria: 'Saúde',
      idConquista: 'elixir_vida',
      xpGanhado: 150,
    );
  }

  // verifica e libera a conquista de registrar gastos por 7 dias consecutivos
  static Future<String?> checarDisciplinaFinanceira(
    List<Map<String, dynamic>> listaGastos,
  ) async {
    try {
      // extrai apenas as datas (ano, mes, dia) e remove duplicadas do mesmo dia
      final datasUnicas = listaGastos
          .map((gasto) {
            final date = (gasto['data'] as Timestamp).toDate();
            return DateTime(date.year, date.month, date.day);
          })
          .toSet()
          .toList();

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
        bool ganhou = await ConquistaDesbloqueio.desbloquear(
          'disciplina_financeira',
          150,
        ); //
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

