import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class HighScoreTile extends StatelessWidget {
  final String documentId;
  const HighScoreTile({
    Key? key,
    required this.documentId,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // get the collection of highscores
    CollectionReference highscores = FirebaseFirestore.instance.collection("highscores");
    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: ((context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          Map<String, dynamic> data = snapshot.data!.data() as 
          Map<String, dynamic>;
          return Row(children: [
            Text(data["score"].toString(),style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
            const SizedBox(width: 10),
            Text(data["name"],style: const TextStyle(color:  Color.fromARGB(252, 255, 255, 255)),),
          ],);
        }else {
          return const Text("loading...");
        }
      }));
  }
}