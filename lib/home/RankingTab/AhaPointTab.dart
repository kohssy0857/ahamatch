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
import "../../parts/FullscreenVideo.dart";

class AhaPointTab extends StatefulWidget {
  AhaPointTab({Key? key}) : super(key: key);
  @override
  _AhaPointTabState createState() => _AhaPointTabState();
}

class _AhaPointTabState extends State<AhaPointTab> {
  final user = FirebaseAuth.instance.currentUser;
  List netaList = [];
  List netaIdList = [];
  var AhaMap = SplayTreeMap();
  double point = 0;
  late DocumentSnapshot<Map<String, dynamic>> netaSnap;
  int i = 0;
  int k = 0;
  int r = 0;
  int lenk = 0;
  Map pointMap = {};
  var docList = List.filled(100, "");
  Stream<List> getNetaList() async* {
    await FirebaseFirestore.instance
        .collection("T05_Toukou")
        .where("T05_Type", isEqualTo: 1)
        .get()
        .then((QuerySnapshot snapshot) async {
      snapshot.docs.forEach((doc) {
        netaIdList.add(doc.id);
      });
      // print(lenk);
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
                .then((neta) {
              netaSnap = neta;
              pointMap[neta.data()!["T05_Title"]] = points.size;
            });
            point = points.size.toDouble();
            if (netaList.length < 10) {
              while (true) {
                if (AhaMap.containsKey(point)) {
                  point += 0.1;
                } else {
                  AhaMap.addAll({point: netaSnap.data()});
                  break;
                }
              }
            }

            netaList = AhaMap.values.toList();
            netaList = netaList.reversed.toList();
            // print(lenk);

            if (netaList.length == 10 && k == 0) {
              // print(pointMap);
              k++;
              netaList.asMap().forEach((int index, netadata) async {
                await FirebaseFirestore.instance
                    .collection("T05_Toukou")
                    .where("T05_Title", isEqualTo: netadata["T05_Title"])
                    .get()
                    .then((value) {
                  docList[index] = value.docs.first.id;
                });
              });
              if (i == 0) {
                print(lenk);
                setState(() {});
                i++;
              }
            }
          }
        });
      });
    });
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getNetaList(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: netaList.length,
              itemBuilder: (context, index) {
                return SizedBox(
                    height: 100,
                    child: ListTile(
                      minVerticalPadding: 0,
                      minLeadingWidth: 100,
                      title: Text(
                          "${netaList[index]["T05_Title"].padRight(40)}${pointMap[netaList[index]["T05_Title"]].toString()}アハポイント"),
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          "${index + 1}位",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 24),
                        ),
                      ),
                      subtitle: Text(netaList[index]["T05_UnitName"]),
                      trailing: Image.network(
                        netaList[index]["T05_Thumbnail"],
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullscreenVideo(
                                    docList[index], 100, 99))).then((value) {
                          // 再描画
                          setState(() {});
                        });
                      },
                    ));
              });
        });
  }
}
