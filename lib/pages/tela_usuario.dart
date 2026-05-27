import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/auth_page.dart';
import 'package:vita_appprojetos/pages/pagina_login.dart';
import 'package:vita_appprojetos/uitl/bottom_nav_bar.dart';

// Função principal que inicia o app
/* void main() {
  runApp(const MyApp());
}

// Widget raiz do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove a faixa "debug"
      theme: ThemeData.dark(), // ativa tema escuro padrão
      home: const ProfileScreen(), // tela inicial
    );
  }
} */

// Tela principal (perfil)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, bool> switchStates;
  late final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    switchStates = {
      "Notificações Push": true,
      "Quizzes Semanais": true,
      "Mostrar Nível XP": false,
      "Mostrar Status do Streak": true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo personalizada (preto/cinza escuro)
      backgroundColor: const Color(0xFF0D0F14),

      // Barra superior
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.transparent, // transparente
        elevation: 0, // remove sombra
      ),

      // Conteúdo da tela com espaçamento
      body: Padding(
        padding: const EdgeInsets.all(16),

        // Permite rolagem
        child: ListView(
          children: [
            _buildProfileCard(), // card do usuário

            const SizedBox(height: 20),

            _buildSectionTitle("Configurações"),

            // Lista de switches (visual apenas)
            _buildSwitchTile("Notificações Push"),
            _buildSwitchTile("Quizzes Semanais"),
            _buildSwitchTile("Mostrar Nível XP"),
            _buildSwitchTile("Mostrar Status do Streak"),

            const SizedBox(height: 20),

            _buildSectionTitle("Dados e Progresso"),

            // Cards informativos (sem ação)
            _buildInfoCard("Refazer Guia de Semana"),
            _buildInfoCard("Limpar Atividade Recente"),

            const SizedBox(height: 20),

            _buildLogoutButton(), // "botão" sair (visual)
          ],
        ),
      ),
    );
  }

  // =========================
  // CARD DE PERFIL
  // =========================
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24), // fundo do card
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Ícone de usuário
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.blueAccent),
          ),

          const SizedBox(height: 10),

          // Nome
          Text(
            user?.displayName ?? 'Usuário',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          // Email
          Text(user!.email!, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          // Estatísticas (nível e streak)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _StatItem(label: "Nível", value: "18"),
              _StatItem(label: "Streak", value: "7"),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // TÍTULO DE SEÇÃO
  // =========================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // SWITCH (CONFIGURAÇÃO)
  // =========================
  Widget _buildSwitchTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          value: switchStates[title]!,
          onChanged: (bool newValue) {
            setState(() {
              switchStates[title] = newValue;
            });
          },
          title: Text(title),
          activeThumbColor: Colors.blueAccent,
        ),
      ),
    );
  }

  // =========================
  // CARD SIMPLES DE TEXTO
  // =========================
  Widget _buildInfoCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(title),
    );
  }

  // =========================
  // "BOTÃO" SAIR (VISUAL)
  // =========================
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Sair da Conta",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

// =========================
// WIDGET DE ESTATÍSTICA
// =========================
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Número (ex: 18)
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),

        // Texto (ex: Nível)
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
