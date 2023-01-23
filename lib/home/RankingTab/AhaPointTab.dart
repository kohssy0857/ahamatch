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
import 'dart:collection';

class AhaPointTab extends StatefulWidget {
  AhaPointTab({Key? key}) : super(key: key);
  @override
  _AhaPointTabState createState() => _AhaPointTabState();
}

class _AhaPointTabState extends State<AhaPointTab> {
  final user = FirebaseAuth.instance.currentUser;
  List netaList = [];
  List netaIdList = [];
  List result = [];
  Map AhaMap = {};
  int setstint = 0;
  late DocumentSnapshot<Map<String, dynamic>> netaSnap;
  var netaHit = "";
  Stream<List> getNetaList() async* {
    await FirebaseFirestore.instance
        .collection("T05_Toukou")
        .where("T05_Type", isEqualTo: 1)
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((doc) {
        netaIdList.add(doc.id);
        // print(doc.get("AhaPoint"));
      });
      netaIdList.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("T05_Toukou")
            .doc(element)
            .collection("AhaPoint")
            .get()
            .then((QuerySnapshot points) async {
          if (points.size > 0) {
            await FirebaseFirestore.instance
                .collection("T05_Toukou")
                .doc(element)
                .get()
                .then((neta) => netaSnap = neta);
            AhaMap.addAll({netaSnap.data(): points.size});
            SplayTreeMap.from(
                AhaMap, (a, b) => AhaMap[a]!.compareTo(AhaMap[b]!));
            netaList.addAll(AhaMap.keys);
            netaList.forEach((neta) {
              if (!result.contains(neta)) {
                result.add(neta);
              }
            });
            netaList = result.reversed.toList();
            print(netaList.length);
            if (netaList.length == 10) {
              netaList.forEach((element) {
              });
              setState(() {});
            }
            // print(netaList[0]);
          }
        });
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
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("読み込み中");
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return SizedBox(
                          child: ListTile(
                              title: Text(netaList.length.toString())));
                    } else {
                      return Text("ddddddddddddddddddddddd");
                    }
                  })
            ],
          );
        });
  }
}
