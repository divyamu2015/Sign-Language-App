import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AboutQuizPage extends StatelessWidget {
  const AboutQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          duration: const Duration(milliseconds: 800),
          child: const Text(
            "🧠 About the Quiz",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 231, 173, 243),
              Color.fromARGB(255, 245, 176, 239),
              //Color.fromARGB(255, 98, 159, 238),
              Color.fromARGB(255, 213, 148, 221),
              Color.fromARGB(255, 231, 173, 243),
              Color.fromARGB(255, 245, 176, 239),
              //Color.fromARGB(255, 98, 159, 238),
              Color.fromARGB(255, 213, 148, 221),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: const [
                      RuleItem(
                        icon: Icons.list_alt_rounded,
                        title: "Multiple Questions",
                        description:
                            "Each level includes a set of interesting and unique questions to challenge your mind.",
                      ),
                      RuleItem(
                        icon: Icons.assignment_turned_in,
                        title: "Complete All",
                        description:
                            "You must attempt all questions in a level to proceed.",
                      ),
                      RuleItem(
                        icon: Icons.score,
                        title: "Score Requirement",
                        description:
                            "A minimum score of 30 is required to unlock the next level.",
                      ),
                      RuleItem(
                        icon: Icons.monetization_on,
                        title: "Earn Coins",
                        description:
                            "Earn 8 coins for every level you complete. Your total reward increases as you progress.",
                      ),
                      RuleItem(
                        icon: Icons.refresh_rounded,
                        title: "Retry If Needed",
                        description:
                            "Didn't hit 30? No worries, you can retry the level as many times as needed!",
                      ),
                      RuleItem(
                        icon: Icons.lock_open_rounded,
                        title: "Unlock Next Level",
                        description:
                            "Once a level is cleared, the next one becomes available for play.",
                      ),
                      RuleItem(
                        icon: Icons.school,
                        title: "Practice Mode",
                        description:
                            "Warm up before you dive into real levels. Practice mode helps you get comfortable.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RuleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const RuleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 700),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(icon, color: Colors.deepPurple),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(description),
        ),
      ),
    );
  }
}
