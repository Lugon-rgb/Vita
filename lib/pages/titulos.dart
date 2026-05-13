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
          'Título default, concedido ao ingressar no Vita.', Icons.lock_open, comum),
          titulo('Novato Determinado', 
          'Atingir a conquista “Primeira Vitória”.', Icons.lock_open, comum),
          titulo('Escrivão', 
          'Atingir a conquista “Anotação de Campo”.', Icons.lock, comum),
          titulo('Vigia das Moedas', 
          'Atingir as conquistas “Pilar de Finanças” e “Registro de Ouro”.', Icons.lock_open, comum),
          titulo('Andarilho', 
          'Atingir o nível 5.', Icons.lock_open, comum),


          rankTitulos('Títulos Incomuns', incomum),

          // TÍTULOS INCOMUNS:
          titulo('Guerreiro do Foco', 
          'Atingir a conquista “Ritmo Semanal”.', Icons.lock_open, incomum),
          titulo('Sábio Resistente', 
          'Atingir as conquistas “Sede de Conhecimento” e “Elixir da Vida”.', Icons.lock_open, incomum),
          titulo('Guardião das Memórias', 
          'Atingir a conquista “Mosaico de Ideias”.', Icons.lock, incomum),
          titulo('Guardião das Moedas', 
          'Atingir a conquista “Disciplina Financeira”.', Icons.lock, incomum),
          titulo('Veterano de Batalhas', 
          'Atingir o nível 15.', Icons.lock_open, incomum),


          rankTitulos('Títulos Raros', raro),

          // TÍTULOS RAROS:
          titulo('Invulnerável', 
          'Atingir as conquistas “Armadura de Ouro” e “Vigor Pleno”.', Icons.lock, raro),
          titulo('Mestre do Tesouro', 
          'Atingir as conquistas “Superávit” e “Muralha financeira”.', Icons.lock_open, raro),
          titulo('Sentinela do Tempo', 
          'Atingir a conquista “Sequência de Guerreiro”.', Icons.lock, raro),
          titulo('Guardião Experiente', 
          'Atingir o nível 30.', Icons.lock_open, raro),
      

          rankTitulos('Títulos Épicos', epico),

          // TÍTULOS ÉPICOS:
          titulo('Imaculado', 
          'Atingir as conquistas “Fortaleza Pessoal” e “Jornada da Perfeição”.', Icons.lock, epico),
          titulo('Governador do Destino', 
          'Atingir as conquistas “Caminho Estruturado” e “Mapa Completo”', Icons.lock_open, epico),
          titulo('Clarividente', 
          'Atingir a conquista “Mente de Cristal”.', Icons.lock, epico),
          titulo('Magnata', 
          'Atingir a conquista “Sonho Realizado”.', Icons.lock_open, epico),
          titulo('Campeão Implacável', 
          'Atingir o nível 50.', Icons.lock_open, epico),


          rankTitulos('Títulos Lendários', lendario),

          // TÍTULOS LENDÁRIOS:
          titulo('Espartano', 
          'Atingir a conquista “Eternidade Vita”.', Icons.lock, lendario),
          titulo('Uzumaki', 
          'Atingir a conquista “Ciclo Perfeito”.', Icons.lock, lendario),
          titulo('Demiurgo', 
          'Atingir as conquistas “Plano de Uma Era” e “Atlas Universal”.', Icons.lock_open, lendario),
          titulo('Midas', 
          'Atingir as conquistas “Cofre de ferro” e “Atlas Universal”.', Icons.lock, lendario),
          titulo('O Imortalizado', 
          'Atingir o nível 75.', Icons.lock_open, lendario),


          rankTitulos('???',misterioso),

          // TÍTULOS OCULTOS: 
          titulo('O Inominável', 
          'Atinge ao salvar uma nota sem preencher o título.', Icons.lock_open, misterioso),
          titulo('Mestre do Centavo', 
          '???', Icons.lock, misterioso),
          titulo('Alma Gêmea', 
          '???', Icons.lock, misterioso),
          titulo('Minimalista absoluto', 
          'Atinge ao ter 0 metas ativas, 0 notas, 0 gastos, mas entrar no app por 7 dias seguidos.', Icons.lock_open, misterioso),
          titulo('Sobrevivente do Caos', 
          '???', Icons.lock, misterioso),
          titulo('Immortalis Vita', 
          'Alcançar o nível 100', Icons.lock_open, misterioso),

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
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Container( // container envolta do icone pra colorir com a cor da raridade
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: corRaridade.withValues(alpha: 0.1), 
            shape: BoxShape.circle, // transformei o container num circulo p ficar mais bonitinho
            border: Border.all(color: corRaridade.withValues(alpha: 0.5), width: 1), 
          ),
          child: Icon(icone, color: Colors.white ),
        ),
        title: Text(nome, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(descricao, style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.702), fontSize: 14)),
      ),
    );
  }
}
