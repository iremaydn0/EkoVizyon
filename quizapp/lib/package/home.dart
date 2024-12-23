import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Quiz',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Testin tamamlanma durumu
  Map<String, bool> testCompletionStatus = {
    'test1': false,
    'test2': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuizButton(context, 'Test 1', 'test1'),
                _buildQuizButton(context, 'Test 2', 'test2'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context, String label, String testId) {
    final isCompleted = testCompletionStatus[testId] ?? false;

    return GestureDetector(
      onTap: isCompleted
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(
              testId: testId,
              onComplete: () {
                setState(() {
                  testCompletionStatus[testId] = true;
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey : Colors.blueAccent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            isCompleted ? 'Tamamlandı' : label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String testId;
  final VoidCallback onComplete;

  const QuizPage({super.key, required this.testId, required this.onComplete});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Dünya kaç günde Güneş etrafında döner?',
      'options': ['365', '30', '7', '100'],
      'answer': '365',
    },
    {
      'question': 'En büyük gezegen hangisidir?',
      'options': ['Venüs', 'Mars', 'Jüpiter', 'Satürn'],
      'answer': 'Jüpiter',
    },
    {
      'question': 'Türkiye’nin başkenti neresidir?',
      'options': ['İstanbul', 'Ankara', 'İzmir', 'Bursa'],
      'answer': 'Ankara',
    },
  ];

  Map<int, String> selectedOptions = {};
  int score = 0;

  void calculateScore() {
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedOptions[i] == questions[i]['answer']) {
        score += 10;
      }
    }
  }

  Future<void> saveResultToFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('quiz_results').doc(widget.testId).set({
        'testId': widget.testId,
        'score': score,
        'completed': true,
        'timestamp': Timestamp.now(),
      });
      print('Result saved to Firebase');
    } catch (e) {
      print('Error saving result: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorular'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['question'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...question['options'].map<Widget>((option) {
                          final isSelected = selectedOptions[index] == option;
                          final isCorrect = option == question['answer'];
                          Color? buttonColor;

                          if (isSelected) {
                            buttonColor = isCorrect ? Colors.green : Colors.red;
                          } else {
                            buttonColor = Colors.grey[200];
                          }

                          return GestureDetector(
                            onTap: () {
                              if (selectedOptions.containsKey(index)) return;
                              setState(() {
                                selectedOptions[index] = option;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: buttonColor,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                calculateScore();
                await saveResultToFirebase();
                widget.onComplete();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Test Sonucu'),
                      content: Text('Toplam Puanınız: $score'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);

                          },
                          child: const Text('Tamam'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Testi Bitir',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
