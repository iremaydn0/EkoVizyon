import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CombinedQuizPage extends StatefulWidget {
  @override
  _CombinedQuizPageState createState() => _CombinedQuizPageState();
}

class _CombinedQuizPageState extends State<CombinedQuizPage> {
  String currentMode = 'quizSelection';
  String selectedQuizId = '';
  int totalScore = 0;
  int currentQuestionIndex = 0;
  int quizScore = 0;
  bool isAnswered = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, List<Map<String, dynamic>>> quizzes = {
    'quiz1': [
      {"question": "Sürdürülebilirlik kavramı neyi ifade eder?",
        "options": [
          "Yalnızca ekonomik kalkınmayı",
          "Doğal kaynakları gelecek nesillere aktaracak şekilde kullanmayı",
          "Yalnızca çevresel sorunları çözmeyi",
          "Teknolojik gelişmeleri hızlandırmayı"],
        "answer":
        "Doğal kaynakları gelecek nesillere aktaracak şekilde kullanmayı"},

      {"question": "Hangisi yenilenebilir enerji kaynağıdır?",
        "options": [
          "Doğalgaz",
          "Kömür",
          "Rüzgar",
          "Nükleer enerji"],
        "answer":
        "Rüzgar"},

      {"question": "Aşağıdaki hangi davranış çevreyi korumaya daha fazla katkı sağlar?",
        "options": [
          "Tek kullanımlık plastik ürünleri tercih etmek",
          "Geri dönüşüm yaparak atıkları değerlendirmek",
          "Gereksiz enerji tüketimini artırmak",
          "Ulaşımda bireysel araç kullanımını artırmak"],
        "answer":
        "Geri dönüşüm yaparak atıkları değerlendirmek"},

      {"question": "Hangisi karbon ayak izimizi azaltmak için alınabilecek bir önlem değildir?",
        "options": [
          "Toplu taşıma kullanmak",
          "Yerel ve mevsimlik ürünler tüketmek",
          "Güneş enerjisi panelleri kullanmak",
          "Daha fazla fosil yakıt tüketmek"],
        "answer":
        "Daha fazla fosil yakıt tüketmek"},

      {"question": "Bir ürünün “sürdürülebilir” olarak kabul edilmesi için hangi kriter önemli değildir?",
        "options": [
          "Çevreye zarar vermeden üretilmiş olması",
          "Üretiminde enerji tasarrufunun sağlanması",
          "Tekrar kullanılabilir ya da geri dönüştürülebilir olması",
          "Üretim maliyetinin yüksek olması"],
        "answer":
        "Üretim maliyetinin yüksek olması"},
    ],

    'quiz2': [
      {"question": "Hangi enerji kaynağı yenilenebilir değildir?",
        "options": [
          "Güneş",
          "Rüzgar",
          "Petrol",
          "Hidroelektrik"],
        "answer":
        "Petrol"},

      {"question": "Enerji tasarrufu yapmak için hangisi önerilir?",
        "options": [
          "LED ampul kullanmak",
          "Cihazları bekleme modunda bırakmak",
          "Gün boyunca tüm ışıkları açık tutmak",
          "Elektrikli cihazları sürekli fişte bırakmak"],
        "answer":
        "LED ampul kullanmak"},

      {"question": "Güneş enerjisinden elektrik üretmek için ne kullanılır?",
        "options": [
          "Türbin",
          "Güneş panelleri",
          "Kömür",
          "Jeneratör"],
        "answer":
        "Güneş panelleri"},

      {"question": "Evinizde enerji tasarrufu yapmak için ne zaman çamaşır yıkamak daha verimlidir?",
        "options": [
          "Sabahın erken saatlerinde",
          "Gece saatlerinde",
          "Gün ortasında",
          "Her zaman"],
        "answer":
        "Gece saatlerinde"},

      {"question": "Enerji tasarruflu beyaz eşyalarda hangi etiketi aramalısınız?",
        "options": [
          "A++",
          "C",
          "Z",
          "E"],
        "answer":
        "A++"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeFirestoreData();
  }

  // Firestore'da quiz durumu ve puanları başlatma
  Future<void> _initializeFirestoreData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    // Eğer kullanıcı verisi yoksa, başlatma işlemi yap
    if (!docSnapshot.exists) {
      Map<String, dynamic> initialData = {
        "name": "Kullanıcı Adı",
        "email": user.email ?? "bilgi yok",
        "quizStatus": {
          "quiz1": {"isTaken": false, "score": 0},
          "quiz2": {"isTaken": false, "score": 0}
        },
        "totalScore": 0, // Toplam puan verisini de ekleyin
      };
      await docRef.set(initialData);
    }
  }

  // Quiz seçiminde kontrol et ve Firestore'daki durumu kontrol et
  Future<void> _selectTest(String quizId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();
    final quizStatus = docSnapshot['quizStatus'];

    if (quizStatus[quizId]['isTaken']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bu testi zaten çözdünüz!")),
      );
    } else {
      setState(() {
        selectedQuizId = quizId;
        currentMode = 'quizPage';
        currentQuestionIndex = 0;
        quizScore = 0;
        isAnswered = false;
      });
    }
  }

  // Soruyu kontrol et
  void _checkAnswer(String selectedOption) {
    if (!isAnswered) {
      if (quizzes[selectedQuizId]![currentQuestionIndex]['answer'] == selectedOption) {
        quizScore += 10;
      }
      setState(() {
        isAnswered = true;
      });
    }
  }

  // Sonraki soruya geçiş yap
  void _nextQuestion() {
    if (currentQuestionIndex < quizzes[selectedQuizId]!.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  // Testi bitir ve Firestore'a güncelleme yap
  Future<void> _finishQuiz() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();
    final quizStatus = docSnapshot['quizStatus'];

    // Quiz durumu güncelle
    quizStatus[selectedQuizId]['isTaken'] = true;
    quizStatus[selectedQuizId]['score'] = quizScore;

    // Toplam puanı güncelle
    final updatedTotalScore = docSnapshot['totalScore'] + quizScore;

    // Firestore verilerini güncelle
    await docRef.update({
      "quizStatus": quizStatus,
      "totalScore": updatedTotalScore,
    });

    setState(() {
      totalScore = updatedTotalScore;
      currentMode = 'quizSelection';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentMode == 'quizSelection') {
      return Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final quizStatus = snapshot.data!['quizStatus'];
            return GridView.count(
              padding: EdgeInsets.all(16),
              crossAxisCount: 2,
              children: quizzes.keys.map((quizId) {
                final isTaken = quizStatus[quizId]['isTaken'];
                return GestureDetector(
                  onTap: () => _selectTest(quizId),
                  child: Card(
                    margin: EdgeInsets.all(8),
                    color: isTaken ? Colors.grey : Colors.white,
                    child: Center(
                      child: Text(
                        quizId.toUpperCase(),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      );
    } else if (currentMode == 'quizPage') {
      final question = quizzes[selectedQuizId]![currentQuestionIndex];
      return Scaffold(
        appBar: AppBar(title: Text('Quiz: $selectedQuizId')),
        body: Column(
          children: [
            Text("Puan: $quizScore", style: TextStyle(fontSize: 18)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(question['question'], style: TextStyle(fontSize: 20)),
            ),
            ...question['options'].map<Widget>((option) {
              Color backgroundColor = Colors.white;
              if (isAnswered) {
                if (option == question['answer']) {
                  backgroundColor = Colors.green;
                } else {
                  backgroundColor = Colors.red;
                }
              }
              return ElevatedButton(
                onPressed: () => _checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                ),
                child: Text(option),
              );
            }).toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() {
                      currentQuestionIndex--;
                      isAnswered = false;
                    }),
                    child: Text("Önceki"),
                  ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    currentQuestionIndex == quizzes[selectedQuizId]!.length - 1
                        ? "Bitir"
                        : "Sonraki",
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Center(child: Text("Hatalı Mod!")),
      );
    }
  }
}
