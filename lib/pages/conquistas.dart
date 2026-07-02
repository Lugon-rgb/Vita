import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vita_appprojetos/data/dicionario_conquista.dart';

class ConquistasPage extends StatelessWidget {
  const ConquistasPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    // NOVO> agora pega o usuario logado no celular pra ver as conquistas que ele ja tem
    final user = FirebaseAuth.instance.currentUser!;


    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('CONQUISTAS'),
      ),
      // novo body enrolando a listview num streambuilder
      body: StreamBuilder<QuerySnapshot>(
        // agora o body vai ter uma Stream que aponta pra subcolecao de conquistas do usuario atual
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('conquistas')
            .snapshots(),
        builder: (context, snapshot) {
          // se o Firebase estiver carregando, bota o círculo de progresso na tela
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          // pega todos os documentos que vieram do Firebase e extrai os IDs deles (ex: 'anotacao_campo')
          final List<String> conquistasLiberadasNoFirebase = snapshot.hasData
              ? snapshot.data!.docs.map((doc) => doc.id).toList()
              : [];

          return ListView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              
              // CONQUISTAS COMUNS:
              rankConquistas('Conquistas Comuns', '+50 xp', comum),
              
              ...listaDeConquistasDoApp.where((conqAtual) => conqAtual.corRaridade == comum).map((dados) {
                // pega a lista de conquistas completa que eu criei no dicionario_conquista, usa o .where justamente pra filtrar 
                // so as comuns e depois o .map funciona como um loop, ele vai pegar cada conquista comum que sobrou depois do filtro, 
                // uma por uma, e vai criar um widget pra ela usando a funcao conquista que eu criei la embaixo.
                // esse ... eh o operador spread, ele serve justamente pra pegar a lista de widgets que a funcao conquista retorna e
                // literalmente espalhar ela ali dentro da ListView, ja que a ListView espera uma lista de widgets

                final bool estaDesbloqueada = conquistasLiberadasNoFirebase.contains(dados.id);
                // esse bool olha pra lista de conquistas liberadas no firebase, aquela temporaria q eu criei ali em cima, e ve se o ID da conquista atual
                // que ta sendo peneirada, ta la dentro, se tiver, ele retorna true pq ta desbloqueada, se nao, ele retorna false

                return conquista( // eh oq monta de fato o widget da conquista, passando o nome, descricao, icone e cor da raridade
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueada ? Icons.check_circle : Icons.lock_outline, // se tiver desbloqueada, icone de check, se nao, icone de bloqueado
                  dados.corRaridade,
                );
              }),


              // CONQUISTAS INCOMUNS:
              rankConquistas('Conquistas Incomuns', '+150 xp', incomum),

              ...listaDeConquistasDoApp.where((conqAtual) => conqAtual.corRaridade == incomum).map((dados) {
                final bool estaDesbloqueada = conquistasLiberadasNoFirebase.contains(dados.id);
                return conquista(
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueada ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),


              // CONQUISTAS RARAS:
              rankConquistas('Conquistas Raras', '+500 xp', raro),
              
              ...listaDeConquistasDoApp.where((conqAtual) => conqAtual.corRaridade == raro).map((dados) {
                final bool estaDesbloqueada = conquistasLiberadasNoFirebase.contains(dados.id);
                return conquista(
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueada ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),


              // CONQUISTAS ÉPICAS:
              rankConquistas('Conquistas Épicas', '+1000 xp', epico),

              ...listaDeConquistasDoApp.where((conqAtual) => conqAtual.corRaridade == epico).map((dados) {
                final bool estaDesbloqueada = conquistasLiberadasNoFirebase.contains(dados.id);
                return conquista(
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueada ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),


              // CONQUISTAS LENDÁRIAS:
              rankConquistas('Conquistas Lendárias', '+5000 xp', lendario),

              ...listaDeConquistasDoApp.where((conqAtual) => conqAtual.corRaridade == lendario).map((dados) {
                final bool estaDesbloqueada = conquistasLiberadasNoFirebase.contains(dados.id);
                return conquista(
                  dados.nome,
                  dados.descricao,
                  estaDesbloqueada ? Icons.check_circle : Icons.lock_outline,
                  dados.corRaridade,
                );
              }),
            ],
          );
        }
      )
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