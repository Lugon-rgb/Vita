import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// mapeamento simples: 1 conquista desbloqueia diretamente 1 titulo
const Map<String, String> mapaConquistaParaTitulo = {
  'primeira_vitoria': 't_novato_determinado',
  'anotacao_campo': 't_escrivao', // ainda depende de uma conquista nao implementada
  'ritmo_semanal': 't_guerreiro_foco',
  'mosaico_ideias': 't_guardiao_memorias',
  'disciplina_financeira': 't_guardiao_moedas',
  'sequencia_guerreiro': 't_sentinela_tempo',
  'sonho_realizado': 't_magnata',
  'eternidade_vita': 't_espartano',
};

// titulos que exigem 2 (ou mais) conquistas desbloqueadas ao mesmo tempo
const Map<String, List<String>> mapaCombosDeConquistas = {
  't_vigia_moedas': ['pilar_financas', 'registro_ouro'],
  't_sabio_resistente': ['sede_conhecimento', 'elixir_vida'],
  't_invulneravel': ['armadura_ouro', 'vigor_pleno'],
  't_mestre_tesouro': ['superavit', 'muralha_financeira'],
  't_imaculado': ['fortaleza_pessoal', 'jornada_perfeicao'],
  't_governador_destino': ['caminho_estruturado', 'mapa_completo'],
  't_demiurgo': ['plano_uma_era', 'atlas_universal'],
  't_midas': ['cofre_ferro', 'atlas_universal'],
};

// titulos desbloqueados so por atingir um certo nivel
const Map<int, String> mapaNivelParaTitulo = {
  5: 't_andarilho',
  15: 't_veterano_batalhas',
  30: 't_guardiao_experiente',
  50: 't_campeao_implacavel',
  75: 't_imortalizado',
  100: 't_immortalis_vita', // NOVO misterioso
};

class TituloDesbloqueio {
  // fila estatica dos titulos desbloqueados nesta "rodada", ainda nao mostrados
  // na tela. serve pra qualquer metodo estatico (que nao tem BuildContext)
  // avisar as telas que algo novo foi desbloqueado, sem precisar mudar a
  // assinatura de nenhum metodo existente
  static final List<String> _titulosPendentes = [];

  // chamado pelas telas (com acesso a context) logo apos qualquer acao que
  // possa ter desbloqueado titulo. esvazia a fila e devolve o que tinha nela
  static List<String> consumirTitulosPendentes() {
    final copia = List<String>.from(_titulosPendentes);
    _titulosPendentes.clear();
    return copia;
  }

  // desbloqueia um titulo especifico pro usuario logado, de forma idempotente
  // (so cria o documento se ele ainda nao existir) - mesmo padrao usado nas
  // conquistas, so que sem dar xp, ja que titulos sao cosmeticos
  static Future<bool> desbloquear(String idDoTitulo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final tituloDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('titulos')
        .doc(idDoTitulo);

    try {
      final docSnapshot = await tituloDocRef.get();
      if (docSnapshot.exists) return false; // ja tinha esse titulo, nao faz nada

      await tituloDocRef.set({'desbloqueado': true});
      _titulosPendentes.add(idDoTitulo); // avisa a fila pra tela poder mostrar depois
      return true;
    } catch (e) {
      print('⚠️ Erro ao salvar título: $e');
      return false;
    }
  }

  // chamada logo apos uma conquista ser desbloqueada de verdade. verifica se
  // essa conquista libera algum titulo simples e/ou se ela completa algum
  // combo de titulo que dependia de mais de uma conquista
  static Future<void> checarTituloPorConquista(String idConquista) async {
    final idTituloSimples = mapaConquistaParaTitulo[idConquista];
    if (idTituloSimples != null) {
      await desbloquear(idTituloSimples);
    }

    await _checarCombos(idConquista);
  }

  static Future<void> _checarCombos(String idConquistaRecemDesbloqueada) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final conquistasRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('conquistas');

    for (final entrada in mapaCombosDeConquistas.entries) {
      final idTitulo = entrada.key;
      final conquistasNecessarias = entrada.value;

      // so vale a pena checar esse combo se a conquista que acabou de ser
      // desbloqueada faz parte dele
      if (!conquistasNecessarias.contains(idConquistaRecemDesbloqueada)) {
        continue;
      }

      bool todasDesbloqueadas = true;
      for (final idConquista in conquistasNecessarias) {
        final doc = await conquistasRef.doc(idConquista).get();
        if (!doc.exists) {
          todasDesbloqueadas = false;
          break;
        }
      }

      if (todasDesbloqueadas) {
        await desbloquear(idTitulo);
      }
    }
  }

  // chamada sempre que o nivel do usuario muda. desbloqueia todos os titulos
  // de nivel que ja tenham sido atingidos (usa >= em vez de == porque o
  // usuario pode pular varios niveis de uma vez, dependendo do xp ganho)
  static Future<void> checarTitulosDeNivel(int nivel) async {
    for (final entrada in mapaNivelParaTitulo.entries) {
      if (nivel >= entrada.key) {
        await desbloquear(entrada.value);
      }
    }
  }

  // ===================================================================
  // NOVO: t_mestre_real - registrar um gasto de exatamente 1 real
  // ===================================================================
  static Future<void> checarMestreDoReal(int valor) async {
    if (valor == 1) {
      await desbloquear('t_mestre_real');
    }
  }

  // ===================================================================
  // NOVO: t_minimalista_absoluto - 0 metas ativas, 0 notas, 0 gastos,
  // mas 7 dias seguidos de streak (entrando no app)
  // ===================================================================
  static Future<void> checarMinimalistaAbsoluto({
    required int metasAtivas,
    required List<dynamic> gastos,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    try {
      // conta quantas notas o usuario tem no total
      final notasSnapshot = await userDocRef.collection('notas').count().get();
      final semNotas = (notasSnapshot.count ?? 0) == 0;

      final condicoesOk = metasAtivas == 0 && semNotas && gastos.isEmpty;

      final docSnapshot = await userDocRef.get();
      final data = docSnapshot.data() ?? {};
      int diasAtuais = (data['diasMinimalista'] ?? 0) as int;

      if (condicoesOk) {
        diasAtuais += 1;
      } else {
        diasAtuais = 0;
      }

      await userDocRef.set({
        'diasMinimalista': diasAtuais,
      }, SetOptions(merge: true));

      if (diasAtuais >= 7) {
        await desbloquear('t_minimalista_absoluto');
      }
    } catch (e) {
      print('⚠️ Erro na checagem do título Minimalista Absoluto: $e');
    }
  }

  // reseta o contador do minimalista quando o streak do usuario quebra
  // (ele deixou de entrar no app por 1+ dias)
  static Future<void> resetarMinimalista() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'diasMinimalista': 0,
    }, SetOptions(merge: true));
  }
}