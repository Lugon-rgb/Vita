
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:vita_appprojetos/pages/auth_page.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;

  late Map<String, bool> switchStates;

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

  void _openAvatarCustomizer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1D24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Personalizar Avatar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FluttermojiCircleAvatar(radius: 50),
            const SizedBox(height: 16),
            Expanded(
              child: FluttermojiCustomizer(
                scaffoldWidth: MediaQuery.of(context).size.width,
                autosave: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildSectionTitle("Configurações"),
            _buildSwitchTile("Notificações Push"),
            _buildSwitchTile("Quizzes Semanais"),
            _buildSwitchTile("Mostrar Nível XP"),
            _buildSwitchTile("Mostrar Status do Streak"),
            const SizedBox(height: 20),
            _buildSectionTitle("Dados e Progresso"),
            _buildInfoCard("Refazer Guia de Semana"),
            _buildInfoCard("Limpar Atividade Recente"),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FluttermojiCircleAvatar(radius: 50),

          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: _openAvatarCustomizer,
            icon: const Icon(
              Icons.edit,
              size: 16,
              color: Colors.blueAccent,
            ),
            label: const Text(
              "Personalizar avatar",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : "Usuário",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user?.email ?? "Sem e-mail",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: "Nível", value: "18"),
              _StatItem(label: "Streak", value: "7"),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildSwitchTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: switchStates[title]!,
        onChanged: (bool value) {
          setState(() {
            switchStates[title] = value;
          });
        },
        title: Text(title),
        activeThumbColor: Colors.blueAccent,
      ),
    );
  }

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

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthPage(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Sair da Conta",
            style: TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

