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

class HitTab extends StatefulWidget {
  HitTab({Key? key}) : super(key: key);
  @override
  _HitTabState createState() => _HitTabState();
}

class _HitTabState extends State<HitTab> {
  final user = FirebaseAuth.instance.currentUser;
  List netaList = [];
  Stream<List> getNetaList() async* {
    await FirebaseFirestore.instance
        .collection("T05_Toukou")
        // .where("T05_Type", isEqualTo: 1)
        .orderBy('T05_ShityouKaisu', descending: true)
        .limit(10)
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((doc) {
        netaList.add(doc.data());
      });
    });
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getNetaList(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: netaList.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                        child: ListTile(
                      title: Text(netaList[index]["T05_Title"]),
                    ));
                  })
            ],
          );
        });
  }
}
