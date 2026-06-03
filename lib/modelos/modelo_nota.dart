import 'package:cloud_firestore/cloud_firestore.dart';

class Nota {
  final String? id; // esse ? eh pra avisar que essa variavel pode ser nula, ja que ao criar a nota no app, 
  // o id dela eh mandado como nulo para o firebase, e eh atribuido a um numero la, como se fosse sua identificacao
  final String titulo;
  final String conteudo;
  final String categoria;
  final DateTime dataHora;

  Nota({
    this.id, // não tem 'required', pq no início pode ser nulo
    required this.titulo, // o this. eh tipo um ponteiro que ta apontando para as variaveis da classe acima
    required this.conteudo, // o required obriga obriga a passar um valor na hora de criar a nota no codigo
    required this.categoria,
    required this.dataHora,
  });

  // converte a nota para um Map (p poder salvar no firebase)
  Map<String, dynamic> toMap() {    // Map<String, dynamic> ====== eh tipo (Chave: Valor); o primeiro, a chave, vai ser sempre string, ja o valor dynamic pode ser qualquer coisa
    return {
      'titulo': titulo,
      'conteudo': conteudo,
      'categoria': categoria,
      'dataHora': Timestamp.fromDate(dataHora), // o firebase usa Timestamp para datas, entao tem q converter a data do flutter para essa antes de usar
    };
  }

  // cria uma nota a partir de um documento que veio do firebase, chamado DocumentSnapshot. entao esse metodo vai traduzir esse documento de volta para um objeto do flutter
  factory Nota.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // transforma os dados de dentro desse documento em um map

    DateTime dataFinal; // criando variavel para ser usada no if

if (data['dataHora'] != null) {
    dataFinal = (data['dataHora'] as Timestamp).toDate(); // esse .toDate eh p desconverter o timestamp que fizemos antes, p voltar pra data padrao do dart
  } else {
    dataFinal = DateTime.now(); // atribui o horario atual do celular para a nota, caso nenhuma data seja atribuida por algum motivo.
    // Como por exemplo, a captura rapida, que nao possui o campo de notas para ser mais eficiente.
  }

    return Nota( 
      id: doc.id, // pega a identificacao que o firebase gerou p esse documento especifico
      titulo: data['titulo'] ?? '', // o ?? eh pra evitar que crashe caso o titulo volte nulo ou em branco, dando o valor '' a variavel em questao. 
      // (geralmente ela nao poderia ter esse valor, mas eh tipo uma valvula de escape para o caso de der problema e voltar com valor nulo, o que faria o app crashar)
      conteudo: data['conteudo'] ?? '',
      categoria: data['categoria'] ?? 'Outros', // esse 'outros' eh para o sistema atribuir a categoria outros caso de problema e voltar com valor nulo, 
      // o que faria o app crashar , entao ele impede esse crash
      dataHora: dataFinal 
    );
  }
}