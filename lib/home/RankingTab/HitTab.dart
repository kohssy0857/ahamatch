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
import "../../parts/FullMoviePlayerWidget.dart";
import "../../parts/MoviePlayerWidget .dart";
import "../../parts/FullscreenVideo.dart";

class HitTab extends StatefulWidget {
  HitTab({Key? key}) : super(key: key);
  @override
  _HitTabState createState() => _HitTabState();
}

class _HitTabState extends State<HitTab> {
  final user = FirebaseAuth.instance.currentUser;
  List netaList = [];
  List netaIdList = [];
  bool nowLis = false;
  Stream<List> getNetaList() async* {
    if (netaList.length < 10) {
      await FirebaseFirestore.instance
          .collection("T05_Toukou")
          .orderBy('T05_ShityouKaisu', descending: true)
          .limit(10)
          .get()
          .then((QuerySnapshot snapshot) async {
        snapshot.docs.forEach((doc) {
          netaIdList.add(doc.reference.id);
          netaList.add(doc.data());
        });
      });
    }
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
                          "${netaList[index]["T05_Title"].padRight(40)}${netaList[index]["T05_ShityouKaisu"].round()}回"),
                      trailing: Image.network(
                        netaList[index]["T05_Thumbnail"],
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                      subtitle: Text(netaList[index]["T05_UnitName"]),
                      leading: Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.brown,
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullscreenVideo(
                                    netaIdList[index], 100, 99))).then((value) {
                          // 再描画
                          setState(() {});
                        });
                      },
                    ));
              });
        });
  }
}
