import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../parts/MoviePlayerWidget .dart';

class sendSinme extends StatefulWidget {
  @override
  _sendSinmeState createState() => _sendSinmeState();
}

class _sendSinmeState extends State<sendSinme> {
  final user = FirebaseAuth.instance.currentUser;
  String toukou = "";
  String bosyuu = "";
  int secret = 0;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  // 入力された内容を保持するコントローラ
  // final inputController = TextEditingController();
  VideoPlayerController? MovieController = null;
  List allUserId = [];

  // title,,
  void _upload(String bosyuu) async {
    String? video;
    String? documentId;
    String? unitName;

    final doc = FirebaseFirestore.instance.collection('T05_Toukou').doc();

    final gid =
        FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid);
    // print("gidってなにーー？？");
    // print(gid);

    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where('T02_GeininId', isEqualTo: gid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach(
                (doc) {
                  documentId = doc.id;
                  unitName = doc["T02_UnitName"];
                },
              ),
            });
    await FirebaseFirestore.instance
        .collection('T01_Person')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        /// usersコレクションのドキュメントIDを取得する
        if (doc.id != user!.uid) {
          allUserId.add(doc.id);
        }
      });
    });
    for (int i = 0; i < allUserId.length; i++) {
      await FirebaseFirestore.instance
          .collection('T01_Person')
          .doc(allUserId[i])
          .collection("Notification")
          .doc()
          .set({
        "Create": Timestamp.fromDate(DateTime.now()),
        "Text": "${unitName}が新芽を投稿しました",
        "unread": true,
      });
    }

    final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);

    // 紹介文、視聴回数は0
    await doc.set({
      'T05_Geinin': id,
      "T05_Create": Timestamp.fromDate(DateTime.now()),
      "T05_Type": 3,
      "T05_Toukou": toukou,
      "T05_Bosyu": bosyuu,
      "T05_Secret": secret,
      "T05_UnitName": unitName,
      "T05_ToukouId": "",
    });
    print("登録できました");
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(labelText: "ネタの募集内容"),
                onChanged: (value) {
                  bosyuu = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "必須です";
                  }
                  return null;
                },
              )),
          // Column2
          // Column3
          // Text(inputText),
          ElevatedButton(
            onPressed: () async {
              // _tachikame();
              if (_formKey.currentState!.validate()) {
                print("登録完了");
                _upload(bosyuu);
                try {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => App()));
                } catch (e) {}
              }
            },
            child: const Text('投稿'),
          ),
        ],
      ),
    );
  }
}
