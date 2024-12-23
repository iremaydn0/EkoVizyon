import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  Color myColor = Color(0xff2d6a4f);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Liderlik Sıralaması',  // Başlık
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: myColor,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('totalScore', descending: true)  // Skorlara göre sıralama
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];

                    return ListTile(
                      leading: index == 0
                          ? Icon(Icons.star, color: Colors.yellow,size: 38,)  // Birinciye sarı yıldız simgesi
                          : CircleAvatar(
                        child: Text((index + 1).toString()),  // Diğerlerine sıralama numarası
                      ),
                      title: Text(user['name'],
                         style: TextStyle(
                         fontSize: 24,fontWeight: FontWeight.bold)),
                      subtitle: Text('Score: ${user['totalScore']}',
                         style: TextStyle(
                         fontSize: 18,
                         )),
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
