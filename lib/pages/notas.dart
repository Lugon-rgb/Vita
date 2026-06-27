import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/modelo_nota.dart';
import 'nova_nota.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {

// controles para capturar os textos da captura rapida e da busca
final TextEditingController _tituloController = TextEditingController();
final TextEditingController _conteudoController = TextEditingController();
final TextEditingController _buscaController = TextEditingController();

// criei uma variavel que aponta pra uma colecao do Firebase das notas
//final CollectionReference _notasCollection = FirebaseFirestore.instance.collection('notas');

// a variavel q antes era estatica, agora tem um get que faz ela ser dinamica e ver baseado no usuario em questao
CollectionReference get _notasCollection {
  final user = FirebaseAuth.instance.currentUser!;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notas');
}

String _filtroCategoria = 'Todas'; // variavel para guardar o filtro de categoria selecionado, comeca com "todas" por padrao
 
//final Stream<QuerySnapshot> _notasStream = FirebaseFirestore.instance.collection('notas').orderBy('dataHora', descending: true).snapshots();// conecta ao firebase uma unica vez, quando abrir a tela,
      // pegando a colecao de notas, ordenando pela data e monitorando em tempo real com esse snapshots. dai toda vez que algo mudar la no firebase, o StreamBuilder que ta mais pra baixo
      // vai receber a nova lista de notas atualizada e redesenhar a tela automaticamente 

// tornando dinamica tb
Stream<QuerySnapshot> get _notasStream {
  final user = FirebaseAuth.instance.currentUser!;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notas')
      .orderBy('dataHora', descending: true)
      .snapshots();
}

@override
  void initState() {
    super.initState();
    // serve pra avisar a tela para checar o "if" de cor do botao salvar a cada letra digitada pelo usuario
    _tituloController.addListener(() { // cria meio q um fiscal pra ficar vigiando o campo de texto do titulo da captura rapida
      if (mounted) setState(() {}); // o mounted serve pra evitar crash, nesse caso seria tipo um "se a tela ainda existir(ou seja, se o usuario nao tiver trocado de aba), redesenhe ela"
      });
    _conteudoController.addListener(() { // mesma coisa, so que com o conteudo, redesenhando a tela a cada letra digitada pelo usuario
      if (mounted) setState(() {}); // entao caso o usuario mudar de tela ou fechar a pagina antes de fechar o teclado, esse controller poderia tentar atualizar a tela ja morta
    }); // mas o mounted impede que isso aconteca.
      _buscaController.addListener(() { // mesmo processo, so que com o campo de busca, pra atualizar a lista de notas em tempo real conforme o usuario digita
        if (mounted) setState(() {}); // entao a cada letra digitada na busca, a tela vai ser redesenhada e a lista de notas vai ser filtrada de novo, mostrando apenas as notas que batem com o texto da busca
      });
  }


  // salvar a nota da Captura Rápida no Firebase
  void _salvarNota() async { // async permite o uso do await
    final String titulo = _tituloController.text.trim(); 
    final String conteudo = _conteudoController.text.trim();

    if (titulo.isEmpty || conteudo.isEmpty) { // isEmpty ja vem programado pelo flutter e dart. assim como isnotempty
        ScaffoldMessenger.of(context).showSnackBar( // olha pra tela atual, identifica onde pode escrever uma mensagem e mostra um aviso 
          const SnackBar(content: Text('Preencha o título e o conteúdo!')), 
        ); // obriga o usuario a preencher ambos titulo e conteudo da captura rapida
        return;
      }

    // pegar a classe nota e por os valores automáticos de categoria e data
    final novaNota = Nota(
      titulo: titulo,
      conteudo: conteudo,
      categoria: 'Outros',      // categoria padrão automática para a captura rápida
      dataHora: DateTime.now(), // pega o horário exato do clique do usuário
    );

    try { // a partir daqui, vamos testar algumas coisas que dependem de internet
     
      await _notasCollection.add(novaNota.toMap()); // esse await eh tipo um pause na execucao enquanto faz o processo de consulta ao firebase
      // e o .toMap() eh uma funcao q eu criei no outro codigo que transforma o objeto em um mapa p o firebase aceitar

      _tituloController.clear();
      _conteudoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota rápida salva com sucesso!')),
      ); // avisa que deu certo! feedback
    }

     catch (e) { // se a internet cair no processo do await, ele pula direto pra ca e guarda o motivo do erro na variavel 'e'
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      ); // avisa que deu errado, feedback do erro em questao enviado pelo firebase
    }
  }

      // funcao p deletar a nota usando o ID que veio da memória
  void _deletarNota(String id) async { // esse async serve pra avisar ao dart 
  // que a funcao vai usar await la dentro e executar processos demorados de internet

    try {
      await _notasCollection.doc(id).delete(); // deleta a nota do id especifico
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota deletada!')), // avisa que deu certo, feedback
      );
    } 
    
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar: $e')), // avisa que deu errado, feedback do erro
      );
    }
  }
    // funcao auxiliar pra mudar a cor do botao do salvar dependendo do que está digitado nos campos 
    Color _definirCorBotaoSalvar() {
      if (_tituloController.text.trim().isNotEmpty && _conteudoController.text.trim().isNotEmpty) { // esse trim eh uma limpeza de texto, removendo espacos em branco inuteis 
      // do inicio e do fim de um texto. Isso tambem impede o usuario de salvar uma captura rapida apenas digitando '   ', apertando espaco sem digitar nada.
        return const Color(0xFF2A4BA0); // azul vivo
      } else {
        return const Color(0xFF1E3A8A); // azul apagado
      }
    }
    // funcao auxiliar pra mudar o texto do botao salvar dependendo do que está digitado nos campos 
    Color _definirCorTextoSalvar() {
      if (_tituloController.text.trim().isNotEmpty && _conteudoController.text.trim().isNotEmpty) {
        return Colors.white; // branco vivo quando pronto para salvar
      } else {
        return const Color.fromARGB(97, 255, 255, 255); // branco meio opaco/cinza quando desativado
      }
    }

  //funcao auxiliar pro pop up que aparece quando usuario tenta deletar uma nota, p prevenir erros
  void _confirmarDeletar(String id) { 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog( // desenha caixinha no meio da tela com aviso, escurece o fundo e bloqueia cliques na tela de traz 
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Apagar nota? Essa ação não poderá ser desfeita.',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal),
          ),
          actions: [
            // criando botao para cancelar acao
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // fecha o alerta sem apagar a nota
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
              ),
            ),
            // botao de confirmar o delete
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // fecha o alerta 
                _deletarNota(id);
              },
              child: const Text(
                'Apagar', // mensagem para deletar de fato
                style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }


// equivalente ao free() em C, libera a memoria sobre esses controles
@override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // titulo + nova nota
            Row(
              // titulo
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text( 
                  "Notas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // botao nova nota ainda so estatico
                ElevatedButton.icon( 
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const NovaNotaPage()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(  
                    'Nova Nota',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A4BA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // captura rapida implementada perfeitamente!
            _construirCapturaRapida(),
            const SizedBox(height: 24),
            

            // barrinha de busca ainda so com textfield
            TextField(
              controller: _buscaController, // aquele controle que le o que veio do textfield
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(

                hintText: 'Pesquisar notas...', // muito maneira essa funcao 
                hintStyle: const TextStyle(color: Color.fromARGB(97, 255, 255, 255)),
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(97, 255, 255, 255), size: 20), // nao da p usar fora do textfield, teria que fazer uma row mesmo

                contentPadding: const EdgeInsets.symmetric(vertical: 12),

                filled: true, // p eu pintar o fundo do textfield, eu aparentemente preciso dizer antes que ele TEM uma cor no fundo, pq eh transparente por padrao
                fillColor: const Color(0xFF1E1E1E), // dai eu pinto, la ele

                enabledBorder: OutlineInputBorder( 
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // eh p tirar a borda, p deixar invisivel a linha em volta da caixa
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A4BA0), width: 1), // aqui eu coloco a borda pra aparecer quando o usuario clica no "busca", p ter um feedback
                ),
              ),
            ),

            const SizedBox(height:16),

            // filtros ainda estaticos
            SingleChildScrollView( // melhor que o listview para listas pequenas, renderiza tudo de uma vez; 
              scrollDirection: Axis.horizontal, // scrolla pros lados p ver os filtros disponiveis
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _filtroCategoria = 'Todas'),
                    child: _construirFiltro('Todas', _filtroCategoria == 'Todas'),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filtroCategoria = 'Estudos'),
                    child: _construirFiltro('Estudos', _filtroCategoria == 'Estudos'),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filtroCategoria = 'Saúde'),
                    child: _construirFiltro('Saúde', _filtroCategoria == 'Saúde'),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filtroCategoria = 'Finanças'),
                    child: _construirFiltro('Finanças', _filtroCategoria == 'Finanças'),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filtroCategoria = 'Pessoal'),
                    child: _construirFiltro('Pessoal', _filtroCategoria == 'Pessoal'),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filtroCategoria = 'Outros'),
                    child: _construirFiltro('Outros', _filtroCategoria == 'Outros'),
                  ),
                ],
              ),
            ),

            const SizedBox(height:20),

            // listagem conectada ao firebase 
            StreamBuilder<QuerySnapshot>( // eh um widget do flutter que atualiza a tela sozinho, redesenhando a lista sempre que algo muda no banco de dados
              stream: _notasStream, // pega a colecao de notas do firebase, ordenando elas pela data, deixando as mais recentes em cima
              // o .snapshots() vai monitorar o que acontece la em tempo real, entao ela que diz se algo mudou // eu ja expliquei isso la em cima, mas vou deixar aqui tb
              builder: (context, snapshot) { // ela eh quem desenha o resultado definitivo. o context localiza o bloco na tela e o snapshot guarda os dados que o firebase devolveu

                // ifs de seguranca, caso ocorra algo inesperado
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white))); // se der erro de internet ou firebase, erro de feedback na tela
                }
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator()); // se tiver carregando, pro usuario saber disso, mostra a bolinha girando na tela
                }
                
                final docs = snapshot.data?.docs ?? []; // se o snapshot tiver dados, pega os documentos, se nao tiver, deixa como lista vazia, pra evitar crash

                final notasFiltradas = docs.map((doc) => Nota.fromDocument(doc)).where((nota) { // converte de volta o doc do firebase pro objeto nota
                  // esse .where eh quem faz a filtragem a partir dos True e False recebidos das condicoes abaixo.
                  final termoBusca = _buscaController.text.toLowerCase().trim(); // pega o que o usuario digitou na busca, deixa tudo minusculo pra comparar sem erro de maiusculo/minusculo, e tira os espacos em branco desnecessarios com o trim()
                  final bateNoTitulo = nota.titulo.toLowerCase().contains(termoBusca); // verifica se o titulo da nota, transformado em minusculo, contem o texto da busca. se tiver, bate com o titulo
                  final bateNoConteudo = nota.conteudo.toLowerCase().contains(termoBusca); // mesma coisa, so que com o conteudo da nota. se tiver, bate no conteudo, bate com o conteudo
                  final bateNaBusca = termoBusca.isEmpty || bateNoTitulo || bateNoConteudo; // a busca só bate se o termo de busca estiver vazio (ou seja, o usuario nao digitou nada, entao todas as notas passam) ou se bater no titulo ou se bater no conteudo.

                  // verifica a categoria clicada nas tags
                  final bateNaCategoria = _filtroCategoria == 'Todas' || nota.categoria == _filtroCategoria; // a categoria só bate se o filtro selecionado for "todas" ou se a categoria da nota for igual ao filtro selecionado
                  

                  
                  return bateNaBusca && bateNaCategoria; // ou seja, a nota so passa pelo .where se for aprovada em ambos os testes
                }).toList();

                if (notasFiltradas.isEmpty) {   // se nao aparecer nenhuma nota, mostra uma mensagem avisando
                  return const Center( 
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Nenhuma nota encontrada...', style: TextStyle(color: Colors.white54)),
                    ),
                  );
                }

                // gerador de lista automático baseado nos documentos do firebase
                return ListView.builder( // constroi apenas os cards visiveis na tela do usuario, pra nao travar o celular com telas excessivas

                  shrinkWrap: true, // encolhe essa lista que está dentro da listview principal do codigo, pra nao dar conflito, entao ocupa so o tamanho exato das notas que tao dentro dela.

                  physics: const NeverScrollableScrollPhysics(), // desativa o scroll dessa listview interna que criamos, pro scroll ficar mais suave 
                  
                  itemCount: notasFiltradas.length, // quantidade de itens que o listview vai criar, baseado na quantidade de notas filtradas que tem pra mostrar

                  itemBuilder: (context, index) { // cria o loop pra rodar de nota em nota

                    final nota = notasFiltradas[index]; // pega a nota atual do loop, baseado no index que o listview passa

                    String dataFormatada = "${nota.dataHora.day.toString().padLeft(2, '0')}/${nota.dataHora.month.toString().padLeft(2, '0')}/${nota.dataHora.year} ${nota.dataHora.hour.toString().padLeft(2, '0')}:${nota.dataHora.minute.toString().padLeft(2, '0')}";
                     // formata bonitinho o texto da data

                    // renderizacao final do loop, desenhando o card com os dados do banco
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _construirCardNota(
                        nota.id!, // passamos o ID do card pro banco saber qual eh, caso queiramos deletar ou editar depois
                        nota.titulo,
                        nota.categoria,
                        nota.conteudo,
                        dataFormatada,
                      ),
                    );
                  },
                );
              },
            ),


           
          ],
        ),
      ),
    );
  }

  // widget auxiliar pro bloco de captura rápida
  Widget _construirCapturaRapida() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141923), // Azul escuro de fundo da captura rápida
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: Color(0xFF2A4BA0), size: 18),
              SizedBox(width: 6),
              Text(
                'CAPTURA RÁPIDA',
                style: TextStyle(
                  color: Color(0xFF2A4BA0),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // input do título
          TextField(
            controller: _tituloController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration( // decora campos de texto em flutter
              hintText: 'Título...', // eh um texto auxiliar pra pessoa saber o que digitar
              hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.384)), 
              // isDense: true,
              contentPadding: const EdgeInsets.all(12), // padding entre o texto e a caixa
              enabledBorder: OutlineInputBorder( // sem estar selecionada
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF262626)),
              ),
              focusedBorder: OutlineInputBorder( // depois de ser selecionada 
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A4BA0)), // a mudanca da cor eh meio q um feedback visual
              ),
            ),
          ),

          const SizedBox(height: 12),

          // input do conteúdo
          TextField(
            controller: _conteudoController,
            maxLines: 3, // nao limita as linhas de fato, ele eh mais pra limitar a altura visualmente
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Conteúdo...',
              hintStyle: const TextStyle(color: Color.fromARGB(97, 255, 255, 255)),
              // isDense: true,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF262626)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A4BA0)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // botao salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _salvarNota, // chama a funcao que salva a nota e adiciona la embaixo
              style: ElevatedButton.styleFrom(
                backgroundColor: _definirCorBotaoSalvar(), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Salvar',
                style: TextStyle(color: _definirCorTextoSalvar(), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // widget auxiliar para criar os botões de Filtro/Tags
  Widget _construirFiltro(String label, bool taSelecionado) {

    Color corDoBotao;
    Color corDoTexto;

    if (taSelecionado == true) {
      corDoBotao = const Color(0xFF2A4BA0); // se tiver selecionado
    } else {
      corDoBotao = const Color(0xFF222222); // se nao
    }

    if (taSelecionado == true) {
      corDoTexto = Colors.white; // se tiver selecionado
    } else {
      corDoTexto = const Color.fromARGB(179, 255, 255, 255); // se nao
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: corDoBotao, // variavel de cor do fundo q criei antes
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: corDoTexto, // variavel de cor do texto q criei antes
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
  // funcao auxiliar pra estruturar o card de cada Nota Salva
  Widget _construirCardNota(
    String id,
    String titulo, 
    String categoria, 
    String conteudo, 
    String dataHora,
  ) {

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // titulo e categoria
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // titulo
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // container da categoria
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(6),
                  ),

                  // a propria categoria
                  child: Text(
                    categoria.toUpperCase(), // faz o texto ficar todo em maiusculo
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // conteudo
            Text(
              conteudo,
              style: const TextStyle(
                color: Color.fromARGB(179, 255, 255, 255),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16), 

            // data e iconezinhos de editar e apagar (agora funcionais)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // datas
                Text(
                  dataHora,
                  style: const TextStyle(
                    color: Color.fromARGB(77, 255, 255, 255),
                  ),
                ),

                Row(
                  children: [

                  // editar funcional
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color.fromARGB(97, 255, 255, 255), size: 20),
                      padding: const EdgeInsets.only(right: 12.0),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        List<String> partesData = dataHora.split(' ')[0].split('/'); // pega a parte da data (oq vem antes do espaco) com split(' ') e depois separa dia, mes e ano com outro split
                        // dessa vez usando barra p separar. devolve entao uma lista com 3 textos, sendo eles dia, mes e ano
                        int dia = int.parse(partesData[0]);
                        int mes = int.parse(partesData[1]); // converte pra int
                        int ano = int.parse(partesData[2]);
                        DateTime dataDoCard = DateTime(ano, mes, dia); // retransforma pra DateTime p poder editar no calendario nativo

                        final notaPreenchida = Nota( // cria o modelo nota preenchido com os dados atuais, p poder enviar p tela de editar
                          id: id,
                          titulo: titulo,
                          categoria: categoria,
                          conteudo: conteudo,
                          dataHora: dataDoCard,
                        );

                        // leva p tela de nova nota, so que vez preenchida com os dados atuais da nota, p poder editar
                        Navigator.of(context).push( 
                          MaterialPageRoute(
                            builder: (context) => NovaNotaPage(notaParaEditar: notaPreenchida), // manda a nota preenchida p variavel notaParaEditar da tela de nova nota
                          ),
                        );
                      },
                    ),

                    // apagar funcional
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color.fromARGB(255, 255, 82, 82), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // tira o padding padrao do IconButton, que eh meio grande, 
                      onPressed: () => _confirmarDeletar(id), // quando clicado, o icone apaga a nota em questao com a funcao deletarNota
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
