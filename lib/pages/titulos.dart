import 'package:flutter/material.dart';
import 'package:vita_appprojetos/data/dicionario_titulos.dart';

class TitulosPage extends StatelessWidget {
  const TitulosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // lista q simula temporariamente como os titulos mudariam com base nos dados la do firebase
    final List<String> titulosLiberadosNoFirebase = [
      't_novato',
      't_novato_determinado',
      't_vigia_moedas',
      't_andarilho',
      't_guerreiro_foco',
      't_sabio_resistente',
      't_veterano_batalhas',
      't_mestre_tesouro',
      't_guardiao_experiente',
      't_governador_destino',
      't_magnata',
      't_campeao_implacavel',
      't_demiurgo',
      't_imortalizado',
      't_inominavel',
      't_minimalista_absoluto',
      't_immortalis_vita',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('TÍTULOS')),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // TÍTULOS COMUNS:
          rankTitulos('Títulos Comuns', comum),

          ...listaDeTitulosDoApp
              .where((tituloAtual) => tituloAtual.corRaridade == comum)
              .map((dados) {
                final bool estaDesbloqueado = titulosLiberadosNoFirebase
                    .contains(dados.id);
                return titulo(
                  context,
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueado ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),

          // TÍTULOS INCOMUNS:
          rankTitulos('Títulos Incomuns', incomum),

          ...listaDeTitulosDoApp
              .where((tituloAtual) => tituloAtual.corRaridade == incomum)
              .map((dados) {
                final bool estaDesbloqueado = titulosLiberadosNoFirebase
                    .contains(dados.id);
                return titulo(
                  context,
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueado ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),

          // TÍTULOS RAROS:
          rankTitulos('Títulos Raros', raro),

          ...listaDeTitulosDoApp
              .where((tituloAtual) => tituloAtual.corRaridade == raro)
              .map((dados) {
                final bool estaDesbloqueado = titulosLiberadosNoFirebase
                    .contains(dados.id);
                return titulo(
                  context,
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueado ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),

          // TÍTULOS ÉPICOS:
          rankTitulos('Títulos Épicos', epico),

          ...listaDeTitulosDoApp
              .where((tituloAtual) => tituloAtual.corRaridade == epico)
              .map((dados) {
                final bool estaDesbloqueado = titulosLiberadosNoFirebase
                    .contains(dados.id);
                return titulo(
                  context,
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueado ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),

          // TÍTULOS LENDÁRIOS:
          rankTitulos('Títulos Lendários', lendario),

          ...listaDeTitulosDoApp
              .where((tituloAtual) => tituloAtual.corRaridade == lendario)
              .map((dados) {
                final bool estaDesbloqueado = titulosLiberadosNoFirebase
                    .contains(dados.id);
                return titulo(
                  context,
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueado ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),

          // TÍTULOS OCULTOS:
          rankTitulos('???', misterioso),

          ...listaDeTitulosDoApp
              .where((tituloAtual) => tituloAtual.corRaridade == misterioso)
              .map((dados) {
                final bool estaDesbloqueado = titulosLiberadosNoFirebase
                    .contains(dados.id);
                return titulo(
                  context,
                  dados.nome,
                  estaDesbloqueado ? dados.descricao : '???',
                  estaDesbloqueado ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),
        ],
      ),
    );
  }

  // criando uma funcao pra criar o titulo de cada bloco de conquistas (rank delas)
  Widget rankTitulos(String rank, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        rank,
        style: TextStyle(
          color: cor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // criando função para criar cada conquista + descrição + ícone + cor da raridade p colorir o circulo do icone
  Widget titulo(
    BuildContext context,
    String nome,
    String descricao,
    IconData icone,
    Color corRaridade,
  ) {
    final bool ehDesbloqueado = icone == Icons.check_circle;

    Color corTextoTitulo;
    Color corTextoDescricao;
    Color corIcone;
    Color corBordaCirculo;
    Color corFundoCirculo;

    if (ehDesbloqueado) {
      corTextoTitulo = Colors.white;
      corTextoDescricao = const Color.fromRGBO(255, 255, 255, 0.702);
      corIcone = corRaridade;
      corBordaCirculo = corRaridade.withValues(alpha: 0.4);
      corFundoCirculo = corRaridade.withValues(alpha: 0.1);
    } else {
      corTextoTitulo = const Color.fromRGBO(255, 255, 255, 0.384);
      corTextoDescricao = const Color.fromRGBO(255, 255, 255, 0.239);
      corIcone = const Color.fromRGBO(117, 117, 117, 1);
      corBordaCirculo = const Color.fromRGBO(255, 255, 255, 0.102);
      corFundoCirculo = Colors.transparent;
    }

    double valorOpacidade;
    if (ehDesbloqueado) {
      valorOpacidade = 1.0;
    } else {
      valorOpacidade = 0.6;
    }

    return GestureDetector(
      onTap: () {
        if (ehDesbloqueado) {
          // Se estiver liberado, fecha a tela e devolve o nome do título para a OverlayPage
          Navigator.pop(context, nome);
        } else {
          // Se estiver bloqueado, avisa o jogador com a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Este título ainda está bloqueado! Continue focando para liberá-lo.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },

      child: Card(
        color: const Color(0xFF1E1E1E),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          leading: Container(
            // container envolta do icone pra colorir com a cor da raridade
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corFundoCirculo,
              shape: BoxShape
                  .circle, // transformei o container num circulo p ficar mais bonitinho
              border: Border.all(color: corBordaCirculo, width: 1),
            ),
            child: Opacity(
              opacity: valorOpacidade,
              child: Icon(icone, color: corIcone),
            ),
          ),
          title: Text(
            nome,
            style: TextStyle(
              color: corTextoTitulo,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            descricao,
            style: TextStyle(color: corTextoDescricao, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
