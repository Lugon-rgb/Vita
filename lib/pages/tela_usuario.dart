import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vita_appprojetos/pages/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

// Tela principal (perfil)
class ProfileScreen extends StatefulWidget {

  final VoidCallback aoClicarNoSeletorDeTitulos; // funcao passada como parametro do overlay p ser usada aqui, vai abrir a tela de titulos


  const ProfileScreen({
    super.key,
    required this.aoClicarNoSeletorDeTitulos, // obrigatoria como parametro
  });

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

    carregarAvatar();
  }

  // CARREGAR AVATAR DO FIREBASE
  Future<void> carregarAvatar() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .get();

  final avatar = doc.data()?['avatar'];

  if (avatar != null) {
    // Salva no SharedPreferences para o fluttermoji ler
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fluttermoji', avatar);
    setState(() {}); // reconstrói o widget com o avatar carregado
  }
}

  // SALVAR AVATAR NO FIREBASE
  Future<void> salvarAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final avatar = FluttermojiController().getFluttermojiOptions();

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .set({
      'avatar': avatar,
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avatar salvo com sucesso!")),
      );
    }
  }

  void _openAvatarCustomizer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1D24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            FluttermojiCircleAvatar(radius: 50),

            const SizedBox(height: 16),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: FluttermojiCustomizer(
                      scaffoldWidth: MediaQuery.of(context).size.width,
                      autosave: true,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: salvarAvatar,
                    child: const Text("Salvar avatar"),
                  ),

                  const SizedBox(height: 10),
                ],
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

            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

            _buildSectionTitle("Dados e Progresso"),

            // Cards informativos (sem ação)
            _buildInfoCard("Refazer Guia de Semana"),
            _buildInfoCard("Limpar Atividade Recente"),

            // cards funcionais (navegam para conquistas e títulos)

            _buildNavigationCard(
              title: "Conquistas",
              icon: Icons.emoji_events_outlined,
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const ConquistasPage()),
                );
              },
            ),
            _buildNavigationCard(
              title: "Títulos",
              icon: Icons.military_tech_outlined,
              onTap: widget.aoClicarNoSeletorDeTitulos, // usa a funcao que veio do overlay como parametro pra abrir a tela de titulos
            ),
            

            const SizedBox(height: 20),

            _buildLogoutButton(), // "botão" sair (visual)
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({ 
  // widget dos cards que vao navegar p conquistas e titulos, recebe como parametro o titulo do card, icone e oq acontece quando clica
  // pode ser usado futuramente para outros cards que navegam pra outras telas, só passar o titulo, icone e o onTap desejado
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap, // detecta o clique pra ativar o ontap passado como parametro
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 68, 138, 255), size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
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
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FluttermojiCircleAvatar(radius: 50),

          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: _openAvatarCustomizer,
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            label: const Text(
              "Personalizar avatar",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            user?.displayName ?? "Usuário",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            user?.email ?? "",
            style: const TextStyle(color: Colors.grey),
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
          fontSize: 15,
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
        onChanged: (value) {
          setState(() {
            switchStates[title] = value;
          });
        },
        title: Text(title),
      ),
    );
  }

      child: Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          value: switchStates[title]!,
          onChanged: (bool newValue) {
            setState(() {
              switchStates[title] = newValue;
            });
          },
          title: Text(title, style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600),
          ),
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
      child: Text(title, style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600),
      ),
    );
  }

  // =========================
  // "BOTÃO" SAIR (VISUAL)
  // =========================
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AuthPage()),
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
            style: TextStyle(color: Colors.redAccent, fontSize: 15,
          fontWeight: FontWeight.w600),
          ),
          ),
        ),
    );
  }
}