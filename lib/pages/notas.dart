import 'package:flutter/material.dart';

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

                // botao nova nota 
                ElevatedButton.icon( 
                  onPressed: () {
                    // abrir a tela de criacao do "nova nota"
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

            // captura rapida
            _construirCapturaRapida(),
            const SizedBox(height: 24),
            

            // barrinha de busca
            TextField(
              controller: _buscaController, // aquele controle que le o que veio do textfield
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(

                hintText: 'Pesquisar notas...', // muito maneira essa funcao pprt
                hintStyle: const TextStyle(color: Color.fromARGB(97, 255, 255, 255)),
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(97, 255, 255, 255), size: 20), // nao da p usar fora do textfield, teria que fazer uma row mesmo

                contentPadding: const EdgeInsets.symmetric(vertical: 12),

                filled: true, // p eu pintar o fundo do textfield, eu aparentemente preciso dizer antes que ele TEM uma cor no fundo, pq eh transparente por padrao
                fillColor: const Color(0xFF1E1E1E), // dai eu pinto (la ele)

                enabledBorder: OutlineInputBorder( 
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // meio que "tira" a borda, deixa meio q invisivel a linha em volta da caixa
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A4BA0), width: 1), // aqui eu coloco a borda pra aparecer quando o usuario clica no "busca", p ter um feedback
                ),
              ),
            ),

            const SizedBox(height:16),

            // filtros
            SingleChildScrollView( // melhor que o listview para listas pequenas, renderiza tudo de uma vez; 
              scrollDirection: Axis.horizontal, // scrolla pros lados p ver os filtros disponiveis
              child: Row(
                children: [
                  _construirFiltro('Todas', true),
                  _construirFiltro('Estudos', false),
                  _construirFiltro('Saúde', false),
                  _construirFiltro('Pessoal', false),
                  _construirFiltro('Outros', false),
                ],
              ),
            ),

            const SizedBox(height:20),

            // cards de notas
            _construirCardNota(
              'Trabalho de IHC entrega 28/4',
              'Estudos',
              'Entrevistar 4 pessoas para o fluxo de user experience e validar as personas criadas.',
              '14/04/2026 22:52'
            ),

            const SizedBox(height:10),

            _construirCardNota(
              'Trabalho de Calculo entrega 11/06',
              'Estudos',
              'Resolver as questoes e apresentar em sala.',
              '16/05/2026 13:41'
            ),

            const SizedBox(height:10),

            _construirCardNota(
              'Psicologa 13 hs',
              'Pessoal',
              'Ir pra psicologa amanha as 13:00.',
              '11/06/2026 15:00'
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar pro bloco de captura rápida
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

          const SizedBox(height: 12), // da um espacinho pro prox campo

          // Input Título
          TextField(
            controller: _tituloController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration( // decora campos de texto em flutter
              hintText: 'Título...', // eh um texto auxiliar pra pessoa saber o que digitar
              hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.384)), 
              // isDense: true,
              contentPadding: const EdgeInsets.all(12), // padding entre o texto e a caixa
              enabledBorder: OutlineInputBorder( // como a borda da caixa fica sem estar selecionada
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF262626)),
              ),
              focusedBorder: OutlineInputBorder( // como a borda fica depois de ser selecionada pelo usuario
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A4BA0)), // a mudanca da cor eh meio q um feedback visual
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Input Conteúdo
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

          // Botão Salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                //aqui vai entrar a logica da aba que vai abrir depois de clicar no "nova nota". 
              },
              style: ElevatedButton.styleFrom( // eh um tipo de botao que parece ser clicavel, c uma certa profundidade
                backgroundColor: const Color(0xFF1E3A8A), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.702), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget auxiliar para criar os botões de Filtro/Tags
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
        color: corDoBotao, // variavel de cor do fundo aplicada aqui
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: corDoTexto, // variavel de cor do texto aplicada aqui
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
  // funcao auxiliar pra estruturar o card de cada Nota Salva
  Widget _construirCardNota(
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

            const SizedBox(height: 8), // espacin de lei

            // conteudo
            Text(
              conteudo,
              style: const TextStyle(
                color: Color.fromARGB(179, 255, 255, 255),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16), 

            // data e iconezinhos de editar e apagar (atualmente, apenas estaticos)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // data
                Text(
                  dataHora,
                  style: const TextStyle(
                    color: Color.fromARGB(77, 255, 255, 255),
                  ),
                ),

                const Row(
                  children: [

                  // editar
                    Padding(
                      padding: EdgeInsets.only(right: 12.0), 
                      child: Icon(Icons.edit_outlined, color: Color.fromARGB(97, 255, 255, 255), size: 20),
                    ),

                    // apagar
                    Icon(Icons.delete_outline, color: Color.fromARGB(255, 255, 82, 82), size: 20),
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