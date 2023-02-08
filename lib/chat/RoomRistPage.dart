import 'dart:ffi';

import 'package:ahamatch/home/ConventionInput.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import '../profile/geininFollowProfile.dart';
import 'ChatPage.dart';

class Chat extends StatefulWidget {
  Chat({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  User? user = FirebaseAuth.instance.currentUser;
  List personIdList = [];
  List unitNameList = [];
  List documentList = [];

  Stream<List> getVideo() async* {
    await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(user!.uid)
        .collection("Follow")
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          documentList.add(doc.get('T05_GeininId'));
        });
      }
    });
    for (int i = 0; i < documentList.length; i++) {
      await FirebaseFirestore.instance
          .collection('T02_Geinin')
          .doc(documentList[i].path.replaceFirst("T02_Geinin/", ""))
          .get()
          .then((DocumentSnapshot snapshot) {
        if (personIdList.contains(snapshot.get('T02_GeininId')) == false) {
          personIdList.add(snapshot.get('T02_GeininId'));
          unitNameList.add(snapshot.get('T02_UnitName'));
        }
      });
    }
    yield unitNameList;
  }

  @override
  Widget build(BuildContext context) {
    return
        // Text("Left"),
        StreamBuilder(
      stream: getVideo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ロード中");
        } else if (snapshot.hasData) {
          List photo = snapshot.data!;
          return
              // Column(
              //   children: [
              //     Text("ログイン情報:${user!.displayName}"),
              //     Expanded(
              //         child: SizedBox(
              //             child:
              Column(
            children: [
              Text(
                "フォロー欄",
                style: TextStyle(
                  fontSize: 60,
                ),
              ),
              Flexible(
                child: ListView.builder(
                    shrinkWrap: true,
                    // padding: EdgeInsets.all(250),
                    itemCount: unitNameList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          // leading: Image.network(T02_Convention[index].T06_image),
                          title: Text(unitNameList[index]),
                          // subtitle: Text(T02Geinin[index].ID), // 商品名
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                        unitNameList[index], personIdList[index])));
                            /* --- 省略 --- */
                          },
                          // subtitle: Text(T01_Audition['price'].toString()), // 価格
                        ),
                      );
                    }),
              )
            ],
          );
        } else {
          return Column(
            children: [
              Text("ログイン情報:${user!.displayName}"),
              Text("芸人をフォローしてください"),
            ],
          );
          // return const Text("not photo");
        }
      },
    );
    // bottomNavigationBar: Footer(),
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}
