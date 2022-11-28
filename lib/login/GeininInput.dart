// ignore_for_file: library_private_types_in_public_api

import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeininInput extends StatefulWidget {
  const GeininInput({Key? key}) : super(key: key);

  @override
  _GeininInput createState() => _GeininInput();
}

class _GeininInput extends State<GeininInput> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();

  void _upload(int type, String name, String id) async {
    final document = await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .get();
    final data = document.exists ? document.data() : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data!["T01_DisplayName"] + "ffffff"),
      ),
    );
    //  var doclist = document.docs;

    // await FirebaseFirestore.instance
    //     .collection('T02_Person') // コレクションID
    //     .doc(user!.uid) // ドキュメントID
    //     .set({
    //   'T02_GeininId': 0,
    //   'T02_UnitName': type,
    //   "T02_PartnerRecruit": false,
    //   "T02_Tags": user,
    //   "T02_describe": name,
    //   'T02_Create': Timestamp.fromDate(DateTime.now()),
    //   "T02_production": user,
    // });
  }

  String name = "名無し";
  String id = "xxxxxx";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              alignment: Alignment.topCenter,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('T01_Person')
                    // .orderBy('createdAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('エラーが発生しました');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.requireData.docs
                      .map<String>((DocumentSnapshot document) {
                    final documentData =
                        document.data()! as Map<String, dynamic>;
                    return documentData['T01_DisplayName']! as String;
                  }).toList();
                  _upload(2, name, id);
                  final reverseList = list.reversed.toList();

                  return ListView.builder(
                    itemCount: reverseList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Text(
                          reverseList[index],
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      )),
    );
  }
}


  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     key: _scaffoldKey,
  //     body: Form(
  //       key: _formKey,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           ElevatedButton(
  //             onPressed: () async {
  //               try {} catch (e) {}
  //             },
  //             child: const Text('送信'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
// }
