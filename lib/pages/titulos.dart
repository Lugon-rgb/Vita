import 'package:flutter/material.dart';

class TitulosPage extends StatelessWidget {
  const TitulosPage({super.key});

static const Color comum = Color.fromRGBO(255, 255, 255, 0.702);
static const Color incomum = Colors.green;
static const Color raro = Colors.blue;
static const Color epico = Colors.purple;
static const Color lendario = Colors.orange;
static const Color misterioso = Color.fromARGB(255, 218, 32, 32);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('TÍTULOS'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          
          // chamada da funcao ddo rank dos TÍTULOS 
          rankTitulos('Títulos Comuns', comum),

          // TÍTULOS COMUNS:
          titulo('Novato', 
          'Título default, concedido ao ingressar no Vita.', Icons.check_circle, comum),
          titulo('Novato Determinado', 
          'Atingir a conquista “Primeira Vitória”.', Icons.check_circle, comum),
          titulo('Escrivão', 
          'Atingir a conquista “Anotação de Campo”.', Icons.lock_outline, comum),
          titulo('Vigia das Moedas', 
          'Atingir as conquistas “Pilar de Finanças” e “Registro de Ouro”.', Icons.check_circle, comum),
          titulo('Andarilho', 
          'Atingir o nível 5.', Icons.check_circle, comum),


          rankTitulos('Títulos Incomuns', incomum),

          // TÍTULOS INCOMUNS:
          titulo('Guerreiro do Foco', 
          'Atingir a conquista “Ritmo Semanal”.', Icons.check_circle, incomum),
          titulo('Sábio Resistente', 
          'Atingir as conquistas “Sede de Conhecimento” e “Elixir da Vida”.', Icons.check_circle, incomum),
          titulo('Guardião das Memórias', 
          'Atingir a conquista “Mosaico de Ideias”.', Icons.lock_outline, incomum),
          titulo('Guardião das Moedas', 
          'Atingir a conquista “Disciplina Financeira”.', Icons.lock_outline, incomum),
          titulo('Veterano de Batalhas', 
          'Atingir o nível 15.', Icons.check_circle, incomum),


          rankTitulos('Títulos Raros', raro),

          // TÍTULOS RAROS:
          titulo('Invulnerável', 
          'Atingir as conquistas “Armadura de Ouro” e “Vigor Pleno”.', Icons.lock_outline, raro),
          titulo('Mestre do Tesouro', 
          'Atingir as conquistas “Superávit” e “Muralha financeira”.', Icons.check_circle, raro),
          titulo('Sentinela do Tempo', 
          'Atingir a conquista “Sequência de Guerreiro”.', Icons.lock_outline, raro),
          titulo('Guardião Experiente', 
          'Atingir o nível 30.', Icons.check_circle, raro),
      

          rankTitulos('Títulos Épicos', epico),

          // TÍTULOS ÉPICOS:
          titulo('Imaculado', 
          'Atingir as conquistas “Fortaleza Pessoal” e “Jornada da Perfeição”.', Icons.lock_outline, epico),
          titulo('Governador do Destino', 
          'Atingir as conquistas “Caminho Estruturado” e “Mapa Completo”', Icons.check_circle, epico),
          titulo('Clarividente', 
          'Atingir a conquista “Mente de Cristal”.', Icons.lock_outline, epico),
          titulo('Magnata', 
          'Atingir a conquista “Sonho Realizado”.', Icons.check_circle, epico),
          titulo('Campeão Implacável', 
          'Atingir o nível 50.', Icons.check_circle, epico),


          rankTitulos('Títulos Lendários', lendario),

          // TÍTULOS LENDÁRIOS:
          titulo('Espartano', 
          'Atingir a conquista “Eternidade Vita”.', Icons.lock_outline, lendario),
          titulo('Uzumaki', 
          'Atingir a conquista “Ciclo Perfeito”.', Icons.lock_outline, lendario),
          titulo('Demiurgo', 
          'Atingir as conquistas “Plano de Uma Era” e “Atlas Universal”.', Icons.check_circle, lendario),
          titulo('Midas', 
          'Atingir as conquistas “Cofre de ferro” e “Atlas Universal”.', Icons.lock_outline, lendario),
          titulo('O Imortalizado', 
          'Atingir o nível 75.', Icons.check_circle, lendario),


          rankTitulos('???',misterioso),

          // TÍTULOS OCULTOS: 
          titulo('O Inominável', 
          'Atinge ao salvar uma nota sem preencher o título.', Icons.check_circle, misterioso),
          titulo('Mestre do Centavo', 
          '???', Icons.lock_outline, misterioso),
          titulo('Alma Gêmea', 
          '???', Icons.lock_outline, misterioso),
          titulo('Minimalista absoluto', 
          'Atinge ao ter 0 metas ativas, 0 notas, 0 gastos, mas entrar no app por 7 dias seguidos.', Icons.check_circle, misterioso),
          titulo('Sobrevivente do Caos', 
          '???', Icons.lock_outline, misterioso),
          titulo('Immortalis Vita', 
          'Alcançar o nível 100', Icons.check_circle, misterioso),

        ],
      ),
    );
  }


// criando uma funcao pra criar o titulo de cada bloco de conquistas (rank delas)
  Widget rankTitulos (String rank, Color cor) {
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
  Widget titulo (String nome, String descricao, IconData icone, Color corRaridade) {

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
    

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Container( // container envolta do icone pra colorir com a cor da raridade
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: corFundoCirculo,
            shape: BoxShape.circle, // transformei o container num circulo p ficar mais bonitinho
            border: Border.all(color: corBordaCirculo, width: 1), 
          ),
          child: Opacity(
            opacity: valorOpacidade,
            child: Icon(icone, color: corIcone),
          ),
        ),
        title: Text(nome, style: TextStyle(color: corTextoTitulo, fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(descricao, style: TextStyle(color: corTextoDescricao, fontSize: 14)),
      ),
    );
  }
}
