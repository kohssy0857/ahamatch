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

class CommentTab extends StatefulWidget {
  CommentTab({Key? key}) : super(key: key);
  @override
  _CommentTabState createState() => _CommentTabState();
}

class _CommentTabState extends State<CommentTab> {
  // ユーザー定義
  final user = FirebaseAuth.instance.currentUser;
  // ネタとそのＩＤのリスト
  List netaList = [];
  List netaIdList = [];
  // ネタとコメント数を対応させるための連想配列
  var ComMap = SplayTreeMap();
  // 順位付のためのポイント用変数
  double point = 0;
  // ネタを格納するための変数
  late DocumentSnapshot<Map<String, dynamic>> netaSnap;
  // 各種インクリメント用変数
  int n = 0;
  int j = 0;
  Map pointMap = {};
  // ドキュメントIDを格納するためのリスト
  List docList = [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  ];
  // ネタをコメント数によって順位付けする非同期関数
  Stream<List> getNetaList() async* {
    // タイプがネタの投稿レコードを取得
    await FirebaseFirestore.instance
        .collection("T05_Toukou")
        .where("T05_Type", isEqualTo: 1)
        .get()
        .then((QuerySnapshot snapshot) async {
      // 各レコードのドキュメントを取得
      snapshot.docs.forEach((doc) {
        netaIdList.add(doc.id);
      });
      netaIdList.forEach((element) async {
        // 各レコードのコメント数を取得
        await FirebaseFirestore.instance
            .collection("T05_Toukou")
            .doc(element)
            .collection("Comment")
            .get()
            .then((QuerySnapshot points) async {
          // コメントがあるレコードのみ対応
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
                if (ComMap.containsKey(point)) {
                  point += 0.1;
                } else {
                  ComMap.addAll({point: netaSnap.data()});
                  break;
                }
              }
            }

            netaList = ComMap.values.toList();
            netaList = netaList.reversed.toList();

            if (netaList.length == 10 && j == 0) {
              print("###################################################");
              j++;
              netaList.asMap().forEach((index, netadata) async {
                await FirebaseFirestore.instance
                    .collection("T05_Toukou")
                    .where("T05_Title", isEqualTo: netadata["T05_Title"])
                    .get()
                    .then((value) {
                  docList[index] = value.docs.first.id;
                });
              });
              if (n == 0) {
                setState(() {});
                n++;
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
                          "${netaList[index]["T05_Title"].padRight(40)}${pointMap[netaList[index]["T05_Title"]].toString()}コメント"),
                      trailing: Image.network(
                        netaList[index]["T05_Thumbnail"],
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                      subtitle: Text(netaList[index]["T05_UnitName"]),
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
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
