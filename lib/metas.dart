import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GoalsPage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
      ),
    );
  }
}

class Goal {
  String title;
  bool completed;

  Goal({
    required this.title,
    this.completed = false,
  });
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<Goal> goals = [];

  int selectedBottomIndex = 1;

  final TextEditingController controller = TextEditingController();

  void addGoal() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      goals.add(
        Goal(
          title: controller.text,
        ),
      );
    });

    controller.clear();
    Navigator.pop(context);
  }

  void showAddGoalModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nova Meta",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Digite sua meta",
                  filled: true,
                  fillColor: const Color(0xFF2A2F3A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text("Criar Meta"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Metas",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: goals.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhuma meta criada ainda",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1D26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value:
                                        goal.completed ? 1 : 0,
                                    minHeight: 10,
                                    backgroundColor:
                                        Colors.white12,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                      goal.completed
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          goal.completed =
                                              !goal.completed;
                                        });
                                      },
                                      icon: Icon(
                                        goal.completed
                                            ? Icons
                                                .check_circle
                                            : Icons
                                                .check_circle_outline,
                                      ),
                                      color: Colors.green,
                                    ),

                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          goals.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                      ),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddGoalModal,
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottomIndex,
        onTap: (index) {
          setState(() {
            selectedBottomIndex = index;
          });
        },
        backgroundColor: const Color(0xFF141821),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: "Metas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: "Notas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Finanças",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}