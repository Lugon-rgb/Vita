import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaEditarQuiz extends StatefulWidget {
  const TelaEditarQuiz({super.key});

  @override
  State<TelaEditarQuiz> createState() => _TelaEditarQuizState();
}

class _TelaEditarQuizState extends State<TelaEditarQuiz> {
  final db = FirebaseFirestore.instance;
  late final String _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _perguntaController = TextEditingController();
  String _tipoSelecionado = 'vida';

  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }

  Future<void> _adicionarPergunta() async {
    if (!_formKey.currentState!.validate()) return;

    await db.collection('users').doc(_uid).collection('Quiz').add({
      'pergunta': _perguntaController.text.trim(),
      'tipo': _tipoSelecionado,
      'criadoEm': FieldValue.serverTimestamp(),
    });

    _perguntaController.clear();
    setState(() => _tipoSelecionado = 'vida');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pergunta adicionada!'),
          backgroundColor: Color.fromARGB(255, 30, 64, 214),
        ),
      );
    }
  }

  Future<void> _removerPergunta(String docId) async {
    await db
        .collection('users')
        .doc(_uid)
        .collection('Quiz')
        .doc(docId)
        .delete();
  }

  void _mostrarDialogEditar(
    String docId,
    String perguntaAtual,
    String tipoAtual,
  ) {
    final editController = TextEditingController(text: perguntaAtual);
    String tipoEdit = tipoAtual;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 26, 29, 30),
          title: const Text(
            'Editar Pergunta',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Pergunta',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 30, 64, 214),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Tipo:', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 12),
                  _chipTipo(
                    'vida',
                    tipoEdit,
                    (v) => setStateDialog(() => tipoEdit = v),
                  ),
                  const SizedBox(width: 8),
                  _chipTipo(
                    'estamina',
                    tipoEdit,
                    (v) => setStateDialog(() => tipoEdit = v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 64, 214),
              ),
              onPressed: () async {
                if (editController.text.trim().isEmpty) return;
                await db
                    .collection('users')
                    .doc(_uid)
                    .collection('Quiz')
                    .doc(docId)
                    .update({
                      'pergunta': editController.text.trim(),
                      'tipo': tipoEdit,
                    });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipTipo(String valor, String selecionado, Function(String) onTap) {
    final ativo = valor == selecionado;
    return GestureDetector(
      onTap: () => onTap(valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ativo
              ? (valor == 'vida'
                    ? Colors.redAccent.withOpacity(0.3)
                    : const Color.fromARGB(255, 33, 207, 178).withOpacity(0.2))
              : Colors.transparent,
          border: Border.all(
            color: ativo
                ? (valor == 'vida'
                      ? Colors.redAccent
                      : const Color.fromARGB(255, 33, 207, 178))
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          valor == 'vida' ? '❤️ Vida' : '⚡ Estamina',
          style: TextStyle(
            color: ativo
                ? (valor == 'vida'
                      ? Colors.redAccent
                      : const Color.fromARGB(255, 33, 207, 178))
                : Colors.grey,
            fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editar Quiz', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // FORMULÁRIO ADICIONAR
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 26, 29, 30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nova Pergunta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _perguntaController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Digite a pergunta'
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Ex: Como você dormiu hoje?',
                      hintStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 30, 64, 214),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Afeta:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      StatefulBuilder(
                        builder: (ctx, setStateLocal) => Row(
                          children: [
                            _chipTipo('vida', _tipoSelecionado, (v) {
                              setStateLocal(() => _tipoSelecionado = v);
                              setState(() => _tipoSelecionado = v);
                            }),
                            const SizedBox(width: 8),
                            _chipTipo('estamina', _tipoSelecionado, (v) {
                              setStateLocal(() => _tipoSelecionado = v);
                              setState(() => _tipoSelecionado = v);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 30, 64, 214),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _adicionarPergunta,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Pergunta'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LISTA DE PERGUNTAS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('users')
                  .doc(_uid)
                  .collection('Quiz') // ← mesmo nome aqui
                  .orderBy('criadoEm', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 30, 64, 214),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma pergunta cadastrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final pergunta = data['pergunta'] ?? '';
                    final tipo = data['tipo'] ?? 'vida';
                    final isVida = tipo == 'vida';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 26, 29, 30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: isVida
                                ? Colors.redAccent
                                : const Color.fromARGB(255, 33, 207, 178),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pergunta,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isVida ? '❤️ Vida' : '⚡ Estamina',
                                  style: TextStyle(
                                    color: isVida
                                        ? Colors.redAccent
                                        : const Color.fromARGB(
                                            255,
                                            33,
                                            207,
                                            178,
                                          ),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () =>
                                _mostrarDialogEditar(doc.id, pergunta, tipo),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  26,
                                  29,
                                  30,
                                ),
                                title: const Text(
                                  'Remover pergunta?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  pergunta,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      _removerPergunta(doc.id);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text(
                                      'Remover',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
