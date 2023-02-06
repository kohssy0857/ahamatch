import 'dart:ffi';

import 'package:ahamatch/home/AuditionInput.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video_player/video_player.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';
import 'package:image_picker/image_picker.dart';

import '../parts/header.dart';
import '../parts/MoviePlayerWidget .dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../parts/FullscreenVideo.dart';
import 'dart:async';
import 'dart:ui' as ui;

class mylist extends StatefulWidget {
  mylist({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _mylistState createState() => _mylistState();
}

class _mylistState extends State<mylist> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoThumbnails = [];
  List<String> videoUrls = [];
  List<String> videoId = [];
  List<String> videoTitle = [];
  // ドキュメント情報を入れる箱を用意
  String documentId = "";
  int count = 0;
  List<String> mylistId = [];

  @override
  // void initState() {
  //     setState(() {
  //       getVideo();
  //     });
  //     super.initState();
  // }

  Stream<List> getVideo() async* {
    await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .collection("mylist")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              if (querySnapshot.docs.isNotEmpty)
                {
                  querySnapshot.docs.forEach(
                    (doc) async {
                      FirebaseFirestore.instance
                          .collection('T05_Toukou')
                          .doc(doc["movieId"])
                          .get()
                          .then((DocumentSnapshot snapshot) {
                        if (snapshot.exists) {
                          if (videoThumbnails
                                  .contains(snapshot.get('T05_Thumbnail')) ==
                              false) {
                            mylistId.add(doc.id);
                            videoThumbnails.add(snapshot.get('T05_Thumbnail'));
                            videoTitle.add(snapshot.get('T05_Title'));
                            videoId.add(snapshot.id);
                          }
                        }
                      });
                    },
                  ),
                }
            });
    if (videoThumbnails.length == 0 && count < 5) {
      setState(() {
        count += 1;
      });
    }
    yield videoThumbnails;
  }

// @override
//   void initState() {
//     data = getVideo();
//     super.initState();
//   }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getVideo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ネタないよ");
        } else if (snapshot.hasData) {
          List photo = snapshot.data!;
          return Column(
            children: [
              Expanded(
                  child: SizedBox(
                      child: ListView.builder(
                          shrinkWrap: true,
                          // padding: EdgeInsets.all(250),
                          itemCount: videoThumbnails.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text("${videoTitle[index]}"),
                                SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Image.network(
                                    photo[index],
                                    width: 300,
                                    height: 300,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FullscreenVideo(
                                                        videoId[index],
                                                        100,
                                                        99))).then((value) {
                                          // 再描画
                                          setState(() {});
                                        });
                                        ;
                                      },
                                      icon: Icon(Icons.fullscreen),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // ボタンが押された際の動作を記述する
                                        final String? selectedText =
                                            await showDialog<String>(
                                                context: context,
                                                builder: (_) {
                                                  return SimpleDialogSample(
                                                      mylistId[index]);
                                                });
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ),
                              ],
                            );
                          }))),
            ],
          );
        } else {
          return Column(
            children: [
              Text("ネタ動画をマイリストに追加してください"),
            ],
          );
          // return const Text("not photo");
        }
      },
    );
    // bottomNavigationBar: Footer(),
  }
}

class SimpleDialogSample extends StatefulWidget {
  String videoId;
  SimpleDialogSample(this.videoId, {Key? key}) : super(key: key);

  @override
  State<SimpleDialogSample> createState() => _SimpleDialogSampleState();
}

class _SimpleDialogSampleState extends State<SimpleDialogSample> {
  User? user = FirebaseAuth.instance.currentUser;
  // アカウント削除
  void deleteNeta(String videoId) async {
    FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid).collection("mylist").doc(videoId).delete();
    print('ボタンが押されました!');
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('　　アハプチ動画削除'),
      children: [
        const Text("          本当にアハプチを削除しますか"),
        SimpleDialogOption(
          child: const Text('削除'),
          onPressed: () async {
            deleteNeta(widget.videoId);
            Navigator.pop(context);
            print('アハプチを削除しました!');
          },
        ),
        SimpleDialogOption(
          child: const Text('キャンセル'),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => HomePage()));
            print('キャンセルされました!');
          },
        )
      ],
    );
  }
}
