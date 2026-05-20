import 'package:flutter/material.dart';


class ConquistasPage extends StatelessWidget {
  const ConquistasPage({super.key});

static const Color comum = Color.fromRGBO(255, 255, 255, 0.702);
static const Color incomum = Colors.green;
static const Color raro = Colors.blue;
static const Color epico = Colors.purple;
static const Color lendario = Colors.orange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('CONQUISTAS'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          
          // chamada da funcao ddo rank das conquistas 
          rankConquistas('Conquistas Comuns', '+50 xp', comum),

          // CONQUISTAS COMUNS:
          conquista('Primeira Vitória', 
          'Conclua uma meta qualquer de curto ou longo prazo.', Icons.check_circle, comum),
          conquista('Anotação de Campo', 
          'Crie sua primeira nota', Icons.lock_outline, comum),
          conquista('Registro de Ouro.', 
          'Registre um gasto ou receita pela primeira vez.', Icons.check_circle, comum),
          conquista('Pilar das Finanças.', 
          'Configure o limite mensal de gastos pela primeira vez.', Icons.check_circle, comum),
          conquista('Identidade Forjada.', 
          'Personalize seu título de perfil pela primeira vez.', Icons.lock_outline, comum),
          conquista('Mente Ágil.', 
          'Conclua uma meta de curto prazo em menos de 24 horas após criá-la.', Icons.lock_outline, comum),


          rankConquistas('Conquistas Incomuns', '+150 xp', incomum),

          // CONQUISTAS INCOMUNS:
          conquista('Ritmo Semanal', 
          'Alcance uma sequência diária de 7 dias.', Icons.check_circle, incomum),
          conquista('Série de Triunfos', 
          'Conclua 5 metas de curto prazo no total.', Icons.lock_outline, incomum),
          conquista('Disciplina Financeira.', 
          'Registre gastos por 7 dias consecutivos.', Icons.lock_outline, incomum),
          conquista('Sede de Conhecimento.', 
          'Conclua 3 metas da categoria “Estudo” em uma única semana.', Icons.check_circle, incomum),
          conquista('Elixir da Vida.', 
          'Conclua 3 metas da categoria “Saúde” em uma única semana.', Icons.check_circle, incomum),
          conquista('Mosaico de Ideias.', 
          'Crie pelo menos 2 notas de cada categoria no total.', Icons.lock_outline, incomum),


          rankConquistas('Conquistas Raras', '+500 xp', raro),

          // CONQUISTAS RARAS:
          conquista('Sequência de Guerreiro', 
          'Alcance uma sequência diária de 30 dias.', Icons.check_circle, raro),
          conquista('Zênite Vital', 
          'Responda o quiz semanal com felicidade máxima durante 4 semanas consecutivas.', Icons.lock_outline, raro),
          conquista('Vigor Pleno.', 
          'Mantenha a Stamina cheia durante 4 semanas.', Icons.lock_outline, raro),
          conquista('Armadura de Ouro.', 
          'Mantenha o HP cheio durante 4 semanas.', Icons.lock_outline, raro),
          conquista('Superávit.', 
          'Termine o mês com o saldo disponível maior que a despesa mensal.', Icons.check_circle, raro),
          conquista('Muralha financeira.', 
          'Passe uma semana inteira sem registrar nenhum “gasto extra”.', Icons.check_circle, raro),


          rankConquistas('Conquistas Épicas', '+1000 xp', epico),

          // CONQUISTAS ÉPICAS:
          conquista('Caminho Estruturado', 
          'Conclua 6 metas a longo prazo no total.', Icons.check_circle, epico),
          conquista('Mente de Cristal', 
          'Responda o quiz semanal por 12 semanas consecutivos (3 meses).', Icons.lock_outline, epico),
          conquista('Fortaleza Pessoal.', 
          'Mantenha HP e Stamina, ao mesmo tempo, acima de 80 durante 12 semanas consecutivas .', Icons.lock_outline, epico),
          conquista('Jornada da Perfeição.', 
          'Complete uma meta a longo prazo sem perder nenhum ponto de HP durante o período.', Icons.lock_outline, epico),
          conquista('Sonho Realizado.', 
          'Complete uma meta da categoria “financeira” de valor maior ou igual a 5 vezes a sua receita mensal.', Icons.check_circle, epico),
          conquista('Mapa Completo.', 
          'Conclua pelo menos 3 metas quaisquer (curto ou longo prazo) de cada categoria .', Icons.check_circle, epico),


          rankConquistas('Conquistas Lendárias', '+5000 xp', lendario),
          // CONQUISTAS LENDÁRIAS:
          conquista('Plano de Uma Era', 
          'Conclua 12 metas a longo prazo no total.', Icons.check_circle, lendario),
          conquista('Eternidade Vita', 
          'Mantenha uma sequência de 100 dias ativos.', Icons.lock_outline, lendario),
          conquista('Cofre de ferro.', 
          'Termine 6 meses consecutivos sem ultrapassar o limite mensal de gastos.', Icons.lock_outline, lendario),
          conquista('Império Pessoal.', 
          'Termine 12 meses consecutivos com saldo positivo (saldo disponível > despesa mensal).', Icons.lock_outline, lendario),
          conquista('Atlas Universal.', 
          'Conclua pelo menos 3 metas a longo prazo de cada categoria.', Icons.check_circle, lendario),
          conquista('Ciclo Perfeito.', 
          'Responda o quiz semanal durante 52 semanas consecutivas (1 ano).', Icons.lock_outline, lendario),
          
        ],
      ),
    );
  }


// criando uma funcao pra criar o titulo de cada bloco de conquistas (rank delas)
  Widget rankConquistas (String rank, String xp, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            rank,
            style: TextStyle(
              color: cor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Text( 
            xp,
            style: TextStyle(
              color: cor.withValues(alpha: 0.7),
              fontSize: 16,  
              fontWeight: FontWeight.bold
            )
          )
        ]
      ),
    );
  }


// criando função para criar cada conquista + descrição + ícone + cor da raridade p colorir o circulo do icone
  Widget conquista (String nome, String descricao, IconData icone, Color corRaridade) {

    final bool ehDesbloqueada = icone == Icons.check_circle;

    Color corTextoTitulo;
    Color corTextoDescricao;
    Color corIcone;
    Color corBordaCirculo;
    Color corFundoCirculo;

    if (ehDesbloqueada) {
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
    if (ehDesbloqueada) {
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