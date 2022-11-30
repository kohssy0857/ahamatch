import 'dart:ffi';

import 'package:ahamatch/home/AuditionInput.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';

import '../parts/header.dart';

class owaraizukiProfile extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: Header(),
          
              body: Column( //RowとStackでも同じ
                children: [
                  
                  Text('マイページ情報：${user!.displayName}====2'),
                  // Image.network(
                  //     "https://${user!.photoURL}"
                  //   ),
                  Text('マイページ情報：https://${user!.photoURL}====2'),
                  Text('マイページ情報：${user!.providerData}====2'),
                ],
                
          ),
          
          // body: Center(
          //   // ユーザー情報を表示
          //   // child: Text('マイページ情報：${user!.displayName}====2'),
            
          // ),
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.add),
          //   onPressed: () async {
          //     await FirebaseAuth.instance.signOut();
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => UserLogin()));
          //     /* --- 省略 --- */
          //   },
          // ),
          // bottomNavigationBar: Footer(),
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
