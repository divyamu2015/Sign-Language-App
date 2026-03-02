import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<dynamic> faqs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    final uri = Uri.parse('${AppConfig.baseUri}/api/faqs/');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          faqs = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load FAQs');
      }
    } catch (e) {
      print("Error fetching FAQs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF2F8), // light blue background
        appBar: AppBar(
          title: const Text("Frequently Asked Questions"),
          backgroundColor: const Color.fromARGB(255, 208, 150, 231),
          elevation: 4,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq['question'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              faq['answer'].trim(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
