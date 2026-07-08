import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/modelo_nota.dart';
import '../data/conquista_desbloqueio.dart';
import '../data/titulo_desbloqueio.dart';

class NovaNotaPage extends StatefulWidget {
  final Nota?
  notaParaEditar; // se a nota vier preenchida, a tela vai funcionar como edicao
  // mas se vier vazia, funciona como criacao
  const NovaNotaPage({super.key, this.notaParaEditar});

  @override
  State<NovaNotaPage> createState() => _NovaNotaPageState();
}

class _NovaNotaPageState extends State<NovaNotaPage> {
  // controles para capturar os textos do titulo, conteudo e data
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  // variaveis para guardar as seleções das caixas de opção
  String _categoriaSelecionada = 'Outros'; // selecionada por padrao
  DateTime? _dataSelecionada; // como eh opcional, pode ser nula

  // variavel que aponta para a colecao de notas do Firebase
  // final CollectionReference _notasCollection = FirebaseFirestore.instance.collection('notas');

  CollectionReference get _notasCollection {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'deslogado')
        .collection('notas');
  }

  @override
  void initState() {
    super.initState();
    // vigia os campos para atualizar a cor do botão salvar em tempo real
    _tituloController.addListener(_atualizarTela);
    _conteudoController.addListener(_atualizarTela);

    // se o notaParaEditar nao for nulo, preenche os campos da nota com os dados antigos p poder editar
    if (widget.notaParaEditar != null) {
      _tituloController.text = widget.notaParaEditar!.titulo;
      _conteudoController.text = widget.notaParaEditar!.conteudo;
      _categoriaSelecionada = widget.notaParaEditar!.categoria;
      _dataSelecionada = widget.notaParaEditar!.dataHora;

      // formatando a data antiga p ela aparecer ja preenchida no input
      _dataController.text =
          "${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}";
    }
  }

  // funcao p atualizar a tela smp que o usuario digitar algo, se tiver ativa ainda
  void _atualizarTela() {
    if (mounted) setState(() {});
  }

  // funcao p abrir a miniatura de data do celular (calendário nativo) e pegar a data escolhida
  void _selecionarData() async {
    final DateTime? escolheu = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2040),
      builder: (context, child) {
        // vou alterar as cores do calendário nativo para combinar com o tema do app
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 30, 64, 214),
              onPrimary: Colors.white,
              surface: Color.fromARGB(255, 26, 29, 30),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (escolheu != null) {
      // se for uma data valida
      setState(() {
        _dataSelecionada =
            escolheu; // guardando a data em uma variavel p depois mandar p firebase
        _dataController.text =
            "${escolheu.day.toString().padLeft(2, '0')}/${escolheu.month.toString().padLeft(2, '0')}/${escolheu.year}";
        // formatei p exibir na caixinha de texto (dd/mm/aaaa)
      });
    }
  }

  // funcao p salvar a nota estruturada no Firebase
  void _salvarNotaCompleta() async {
    final String titulo = _tituloController.text.trim();
    final String conteudo = _conteudoController.text
        .trim(); //tipo o rstrip no python

    // medida de seguranca, pra caso ocorra algum bug e o usuario consiga clicar no botao de salvar mesmo com os campos obrigatorios vazios
    if (titulo.isEmpty || conteudo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o título e o conteúdo obrigatórios!'),
        ),
      );
      return;
    }

    // se o usuario escolheu uma data usar ela
    // se nao escolheu (ja q eh opcional), usar o DateTime.now() igual na captura rapida.
    DateTime dataFinal = _dataSelecionada ?? DateTime.now();

    final novaNota = Nota(
      id: widget
          .notaParaEditar
          ?.id, // se tiver vazio, o firebase gera um id novo. se tiver preenchida (para editar), mantém o id antigo,
      titulo: titulo,
      conteudo: conteudo,
      categoria: _categoriaSelecionada,
      dataHora: dataFinal,
    );

    try {
      // junta tudo que essa acao desbloqueou, pra devolver pra NotasPage
      // mostrar depois que essa tela ja tiver fechado
      List<String> conquistasDesbloqueadas = [];

      if (widget.notaParaEditar == null) {
        await _notasCollection.add(
          novaNota.toMap(),
        );

        //desbloqueio de conquista anotacao de campo
        bool ganhouAnotacao = await ConquistaDesbloqueio.desbloquear(
          'anotacao_campo',
          50,
        );
        if (ganhouAnotacao) conquistasDesbloqueadas.add('anotacao_campo');
      } else {
        await _notasCollection
            .doc(widget.notaParaEditar!.id)
            .update(
              novaNota.toMap(),
            );
      }

      // desbloqueio de conquista mosaico de ideias
      String? nomeConquistaMosaico = await ConquistaDesbloqueio.mosaicoIdeias();
      if (nomeConquistaMosaico != null) conquistasDesbloqueadas.add('mosaico_ideias');

      // titulos que essa acao desbloqueou
      final titulosDesbloqueados = TituloDesbloqueio.consumirTitulosPendentes();

      if (mounted) {
        // fecha a tela na hora e devolve pra NotasPage o que foi desbloqueado
        Navigator.of(context).pop({
          'notaCriada': widget.notaParaEditar == null,
          'conquistas': conquistasDesbloqueadas,
          'titulos': titulosDesbloqueados,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar nota: $e')));
    }
  }

  // funcao auxiliar q vai retornar true se os campos obrigatorios estiverem preenchidos
  bool _camposPreenchidos() {
    return _tituloController.text.trim().isNotEmpty &&
        _conteudoController.text.trim().isNotEmpty;
    //usei isso pra poder mudar a cor do botao de salvar mais tarde, caso estejam preenchidos
  }

  // liberando as variaveisde controle da memoria quando a tela for fechada
  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // lista de opções pro dropdown das categorias
    final List<String> categorias = [
      'Estudos',
      'Saúde',
      'Finanças',
      'Pessoal',
      'Outros',
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // setinha p voltar
          onPressed: () => Navigator.of(context).pop(), // fecha a tela
        ),
        title: Text(
          widget.notaParaEditar == null ? 'Nova Nota' : 'Editar Nota',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            // campo do titulo
            const Text(
              'Título',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tituloController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _customInputDecoration(
                'Ex: Resumo de Álgebra Linear...',
              ),
            ),

            const SizedBox(height: 20),

            // campo da categoria com um dropdown
            const Text(
              'Categoria',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue:
                  _categoriaSelecionada, //valor selecionado atualmente
              dropdownColor: const Color.fromARGB(255, 26, 29, 30),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              decoration: _customInputDecoration(
                '',
              ), // como ele ja exibe a categoria selecionada, n precisa do hint text,
              // entao eu pus uma string vazia so p poder usar a decoracao da funcao em questao
              items: categorias.map((String categoria) {
                // esse .map transforma cada string da lista em widgets do tipo DropdownMenuItem,
                // que eh o formato que o dropdown precisa pra exibir as opções
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),

              onChanged: (String? novoValor) {
                if (novoValor != null) {
                  setState(() {
                    _categoriaSelecionada =
                        novoValor; // muda a variavel pra nova escolha de categoria
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // campo da data
            const Text(
              'Data (Opcional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dataController,
              readOnly:
                  true, // impede o usuário de abrir o teclado físico do celular
              onTap:
                  _selecionarData, // abre o calendário q settei antes ao clicar
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _customInputDecoration('dd/mm/aaaa').copyWith(
                suffixIcon: const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // campo do conteudo
            const Text(
              'Conteúdo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _conteudoController,
              maxLines: 6, // campo maiorzinho p caber o bloco de notas de texto
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _customInputDecoration(
                'Digite os detalhes da nota aqui...',
              ),
            ),

            const SizedBox(height: 35),

            // botao de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _camposPreenchidos()
                    ? _salvarNotaCompleta
                    : null, // a opcao de clicar fica desativada se os campos obrigatorios estiverem vazios
                icon: const Icon(Icons.save, size: 18),
                label: const Text(
                  'Salvar Nota',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  // trocar a cor do botao dependendo se os campos obrigatorios estao preenchidos ou nao, p dar um feedback visual pro usuario
                  backgroundColor: _camposPreenchidos()
                      ? const Color.fromARGB(255, 30, 64, 214)
                      : const Color.fromARGB(255, 20, 34, 110),
                  foregroundColor: _camposPreenchidos()
                      ? Colors.white
                      : Colors.white38,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // funcao auxiliar so p poder padronizar a decoracao dos inputs
  InputDecoration _customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      filled: true,
      fillColor: const Color.fromARGB(255, 26, 29, 30), // cor de dentro da caixa
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.white24,
        ), // cor da borda sem estar em foco
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.blue,
        ), // cor da borda em foco
      ),
    );
  }
}