import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vita_appprojetos/pages/auth_page.dart';
import 'package:vita_appprojetos/pages/conquistas.dart';
import 'package:vita_appprojetos/uitl/auth_util.dart';
import 'package:vita_appprojetos/uitl/dialog_box.dart';
import 'package:vita_appprojetos/uitl/reAuth_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? aoClicarNoSeletorDeTitulos;

  const ProfileScreen({super.key, this.aoClicarNoSeletorDeTitulos});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, bool> switchStates;
  final User? user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  int nivel = 1;
  int streak = 0;

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
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (user == null) return;
    try {
      final dados = await db.collection('users').doc(user!.uid).get();
      if (dados.exists && mounted) {
        // ignore: unnecessary_cast
        final data = dados.data() as Map<String, dynamic>? ?? {};
        setState(() {
          nivel = data['nivel'] ?? 1;
          streak = data['streak'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    }
  }

  Future<void> carregarAvatar() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final avatar = doc.data()?['avatar'];

      if (avatar != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fluttermoji', avatar);
        if (mounted) setState(() {});
      }
    } catch (_) {
      // Mantém o perfil funcionando mesmo se o avatar não puder ser carregado.
    }
  }

  Future<void> salvarAvatar() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final avatar = await FluttermojiController().getFluttermojiOptions(); // <- await adicionado

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'avatar': avatar}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar salvo com sucesso!")),
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar avatar: $e')),
        );
      }
    }
  }

  void _openAvatarCustomizer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 26, 29, 30),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 30, 64, 214),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
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
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: AppBar(
        title: const Text("Perfil", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),
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
            _buildNavigationCard(
              title: "Conquistas",
              icon: Icons.emoji_events_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConquistasPage(),
                  ),
                );
              },
            ),
            _buildNavigationCard(
              title: "Títulos",
              icon: Icons.military_tech_outlined,
              onTap: widget.aoClicarNoSeletorDeTitulos ?? () {},
            ),
            const SizedBox(height: 20),
            _buildLogoutButton(),
            SizedBox(height: 10),
            _buildAccountDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _emailNverficado() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              constraints: BoxConstraints(maxHeight: 250),
              title: const Center(
                child: Text(
                  "Verificação de Email",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 26, 29, 30),
              content: const SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      "Click abaixo para re-enviar o email de verificação",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25),
                    Text(
                      "(Você será desconectado, log novamente após verificar seu email)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await user!.sendEmailVerification();
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthPage()),
                      );
                    }
                  },
                  child: const Text(
                    "Enviar",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    "Fechar",
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 25,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: 17),
                Icon(
                  Icons.close,
                  color: const Color.fromARGB(255, 255, 35, 35),
                ),
                SizedBox(width: 2),
                Text("Email", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailVerficado() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              constraints: BoxConstraints(maxHeight: 190),
              title: const Center(
                child: Text(
                  "Email Verificado",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 26, 29, 30),
              content: const SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      "Seu endereço de email já foi verificado",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    "Fechar",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 25,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: 17),
                Icon(
                  Icons.check,
                  color: const Color.fromARGB(255, 61, 213, 71),
                ),
                SizedBox(width: 2),
                Text("Email", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indEmail() {
    bool emailVeri = user!.emailVerified;
    if (emailVeri) {
      return _emailVerficado();
    } else {
      return _emailNverficado();
    }
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 29, 30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _indEmail(),
          FluttermojiCircleAvatar(radius: 50),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _openAvatarCustomizer,
            icon: const Icon(Icons.edit, color: Colors.blue),
            label: const Text(
              "Personalizar avatar",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.displayName ?? 'Usuário',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Email não informado',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: "Nível", value: '$nivel'),
              _StatItem(label: "Streak", value: '$streak dias'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 26, 29, 30),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color.fromARGB(255, 30, 64, 214),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
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
        color: const Color.fromARGB(255, 26, 29, 30),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          value: switchStates[title] ?? false,
          onChanged: (bool newValue) {
            setState(() {
              switchStates[title] = newValue;
            });
          },
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          activeThumbColor: const Color.fromARGB(255, 30, 64, 214),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 29, 30),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            "Sair da Conta",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDeleteButton() {
    final AuthUtil _auth = AuthUtil();
    final _emailUsuario = TextEditingController();
    final _senhaUsuario = TextEditingController();

    Future<dynamic> credReconfirm() {
      return showDialog(
        context: context,
        builder: (_) {
          return ReAuthDialogBox(
            email: _emailUsuario,
            senha: _senhaUsuario,
            onConfirm: () async {
              try {
                await _auth.reauthUser(
                  email: _emailUsuario.text.trim(),
                  senha: _senhaUsuario.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context); // fecha o ReAuthDialog
                  showDialog(
                    context: context,
                    builder: (_) {
                      return DialogBox(
                        sim: () async {
                          Navigator.pop(context);
                          print('Deletando conta...');
                          await _auth.deleteUser();
                          print('Conta deletada!');
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthPage(),
                              ),
                            );
                          }
                        },
                        nao: () => Navigator.pop(context),
                      );
                    },
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Credenciais incorretas. Tente novamente.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          );
        },
      );
    }

    Future<dynamic> confirmDialog() {
      return showDialog(
        context: context,
        builder: (_) {
          return DialogBox(
            sim: () {
              Navigator.pop(context);
              credReconfirm();
              // delete account logic here
            },
            nao: () => Navigator.pop(context),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        confirmDialog();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            "Excluir Conta",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
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

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 30, 64, 214),
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}