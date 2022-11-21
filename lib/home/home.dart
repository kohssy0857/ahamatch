import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/header.dart';

class Home extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  // var user_Q = FirebaseFirestore.instance
  //     .collection('T01_Person')
  //     .where('T01_AuthId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  // var jij = user_conf.then((value) => null);
  //     final user_gi=
  // Stream<Hoge> hogeStream({required DocumentReference<Hoge> ref}) =>
  //     ref.snapshots().map(
  //           (snapshot) => snapshot.data()!,
  //         );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Center(
        // ユーザー情報を表示
        child: Text('ログイン情報：${user!.displayName}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserLogin()));
          /* --- 省略 --- */
        },
      ),
    );
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}
