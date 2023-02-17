import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import 'footer.dart';

import 'header.dart';
import '../parts/searchAccount.dart';
import '../functions.dart';
import '../parts/MoviePlayerWidget .dart';
import 'Search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../parts/FullscreenVideo.dart';
import '../homeTab/netaTab.dart';

class searchNeta extends StatefulWidget {
  final String word;
  searchNeta({
    Key? key,
    required this.word,
  }) : super(key: key);
  // Home(){
  // }
  @override
  _searchNetaState createState() => _searchNetaState();
}

class _searchNetaState extends State<searchNeta> {
  User? user = FirebaseAuth.instance.currentUser;

  List<String> videoThumbnails = [];
  List<String> videoShoukai = [];
  List<String> title = [];
  List<String> videoUrls = [];
  List<String> searchedNames = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];
  List<String> videoTitle = [];
  Map<String, String> geininUnitNameList = {};
  List<String> geininIdList = [];

  Stream<Map> getVideo(String word) async* {
    // final ref =  FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
    // if (documentList.isNotEmpty == true) {
    // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
    await FirebaseFirestore.instance
        .collection('T05_Toukou')
        .where("T05_Type", isEqualTo: 1)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        // if (doc["T05_Type"] == 1) {
        title.add(doc["T05_Title"]);
        FirebaseFirestore.instance
            .collection('T02_Geinin')
            .doc(
                "${doc.get('T05_Geinin').path.replaceFirst("T02_Geinin/", "")}")
            .get()
            .then((DocumentSnapshot snapshot) {
          // geininUnitNameList.add(snapshot.get('T02_UnitName'));
          geininUnitNameList[
                  "${doc.get('T05_Geinin').path.replaceFirst("T02_Geinin/", "")}"] =
              snapshot.get('T02_UnitName');
        });
      });
    });
    if (widget.word.trim().isEmpty) {
      searchedNames = [];

      if (searchedNames.isEmpty) {
        searchedNames =
            title.where((element) => element.contains(word)).toList();
      }

    }
    
    if (searchedNames.isNotEmpty && toukouList.isEmpty) {

      print("search = ${searchedNames}");
      print("length = ${toukouList.length}");
      for(int i = 0;i<searchedNames.length; i++){
          await FirebaseFirestore.instance
              .collection('T05_Toukou')
              .where("T05_Title", isEqualTo: searchedNames[i])
              .where("T05_Type", isEqualTo: 1)
              .get()
              .then((QuerySnapshot snapshot) {
                snapshot.docs.forEach((doc) {
                // if (doc["T05_Type"] == 1) {
                videoUrls.add(doc["T05_VideoUrl"]);
                toukouList.add(doc.id);
                videoThumbnails.add(doc["T05_Thumbnail"]);
                videoShoukai.add(doc["T05_Shoukai"]);
                videoTitle.add(doc["T05_Title"]);
                geininIdList.add(doc.get('T05_Geinin').path.replaceFirst("T02_Geinin/", ""));
              //   FirebaseFirestore.instance
              //     .collection('T02_Geinin')
              //     .doc(
              //         "${doc.get('T05_Geinin').path.replaceFirst("T02_Geinin/", "")}")
              //     .get()
              //     .then((DocumentSnapshot snapshot) {
              //   // geininUnitNameList.add(snapshot.get('T02_UnitName'));
              //   geininUnitNameList["${doc.get('T05_Geinin').path.replaceFirst("T02_Geinin/", "")}"] 
              //   = snapshot.get('T02_UnitName');
              // });
            });

          });
        });
      }
      yield geininUnitNameList;
    }
    // yield videoThumbnails;

    // 取得した動画URLのリストを
    // var url = await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getVideo(widget.word),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ロード中");
        } else if (snapshot.hasData && toukouList.isNotEmpty) {
          // List photo = snapshot.data!;
          print(snapshot);
          return ListView.builder(
              shrinkWrap: true,
              // padding: EdgeInsets.all(250),
              itemCount: videoThumbnails.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    // Text("${geininUnitNameList[geininIdList[index]]}"),
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchResultMane(
                                          word:
                                              "${geininUnitNameList[geininIdList[index]]}",
                                          type: 2,
                                        )));
                          } catch (e) {}
                        },
                        child: SizedBox(
                          width: 100,
                          child: Text(
                              '${geininUnitNameList[geininIdList[index]]}'),
                        )),
                    Column(
                      children: [

                        // Text("${geininUnitNameList[geininIdList[index]]}"),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>


                                                SearchResultMane(word: "${geininUnitNameList[geininIdList[index]]}",type: 2,))


                                                    );
                            } catch (e) {}
                          },
                          child: SizedBox(width: 100,
                                    child: Text('${geininUnitNameList[geininIdList[index]]}'),)
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 500,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(255, 255, 166, 77)),
                              ),
                              child: Text("紹介文：" + "${videoShoukai[index]}"),
                            ),
                            IconButton(
                              onPressed: () async {
                                final result =
                                    await DialogUtils.showEditingDialog(
                                        context, toukouList[index]);
                                // setState(() {
                                //   // shinmeToukouList[index] = result ?? shinmeToukouList[index];
                                // });
                              },
                              icon: Icon(Icons.textsms),
                            ),
                            IconButton(
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullscreenVideo(
                                            toukouList[index], 100, 99))).then(
                                    (value) {
                                  // 再描画
                                  setState(() {});
                                });
                                ;
                              },
                              icon: Icon(Icons.fullscreen),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                );
              });
        } else {
          return Column(
            children: [
              Text("該当するデータはありません"),
            ],
          );
          // return const Text("not photo");
        }
      },
    );
  }
}

class DialogUtils {
  DialogUtils._();

  /// 入力した文字列を返すダイアログを表示する
  static Future<String?> showEditingDialog(
      BuildContext context, String id) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(id: id);
      },
    );
  }
}
