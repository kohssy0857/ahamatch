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

class geininFollwToukou extends StatefulWidget {
  String geininFollowId;
  geininFollwToukou({Key? key, required this.geininFollowId}) : super(key: key);
  // Home(){
  // }
  @override
  _geininFollwToukouState createState() => _geininFollwToukouState();
}

class _geininFollwToukouState extends State<geininFollwToukou> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoThumbnails = [];
  List<String> videoUrls = [];
  List<String> videoId = [];
  // ドキュメント情報を入れる箱を用意
  String documentId = "";
  List<String> videoTitle = [];

  @override
  // void initState() {
  //   // getVideo();
  //   setState(() {});
  //   // super.initState();
  // }

  Stream<List> getVideo() async* {
    // final gid = FirebaseFirestore.instance
    //     .collection("T01_Person")
    //     .doc(user!.uid);
    //   await FirebaseFirestore.instance
    //     .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
    //   (QuerySnapshot querySnapshot) => {
    //       querySnapshot.docs.forEach(
    //         (doc) {
    //           documentId=doc.id;
    //         },
    //       ),
    //     });

    final geininId = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(widget.geininFollowId);

    await FirebaseFirestore.instance
        .collection('T05_Toukou')
        .where("T05_Geinin", isEqualTo: geininId)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc["T05_Type"] == 1) {
          if (videoThumbnails.contains(doc["T05_Thumbnail"]) == false) {
            videoThumbnails.add(doc["T05_Thumbnail"]);
            videoUrls.add(doc["T05_VideoUrl"]);
            videoId.add(doc.id);
            videoTitle.add(doc["T05_Title"]);
          }
        }
      });
    });
    //     final ref = await FirebaseFirestore.instance.collection('T05_Toukou').doc("NVtS0y9o3JB0zjUwLPvv").get();
    //     videoUrls.add(ref.data()!["T05_Thumbnail"]);
    yield videoThumbnails;
  }

  @override
  Widget build(BuildContext context) {
    // initState();
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
                                IconButton(
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FullscreenVideo(videoId[index],
                                                    100, 99))).then((value) {
                                      // 再描画
                                      setState(() {});
                                    });
                                    ;
                                  },
                                  icon: Icon(Icons.fullscreen),
                                ),
                              ],
                            );
                          }))),
            ],
          );
        } else {
          return Column(
            children: [
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

class geininToukou extends StatefulWidget {
  geininToukou({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _geininToukouState createState() => _geininToukouState();
}

class _geininToukouState extends State<geininToukou> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoThumbnails = [];
  List<String> videoUrls = [];
  List<String> videoId = [];
  // ドキュメント情報を入れる箱を用意
  String documentId = "";
  List<String> videoTitle = [];

  @override
  // void initState() {
  //   // getVideo();
  //   setState(() {});
  //   // super.initState();
  // }

  Stream<List> getVideo() async* {
    final gid =
        FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid);
    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where('T02_GeininId', isEqualTo: gid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach(
                (doc) {
                  documentId = doc.id;
                },
              ),
            });

    final geininId = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);

    await FirebaseFirestore.instance
        .collection('T05_Toukou')
        .where("T05_Geinin", isEqualTo: geininId)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc["T05_Type"] == 1) {
          if (videoThumbnails.contains(doc["T05_Thumbnail"]) == false) {
            videoThumbnails.add(doc["T05_Thumbnail"]);
            videoUrls.add(doc["T05_VideoUrl"]);
            videoId.add(doc.id);
            videoTitle.add(doc["T05_Title"]);
          }
        }
      });
    });
    //   print("サムネイルーーーーーーーーーーーー");
    //   print(videoUrls);
    //     final ref = await FirebaseFirestore.instance.collection('T05_Toukou').doc("NVtS0y9o3JB0zjUwLPvv").get();
    //     videoUrls.add(ref.data()!["T05_Thumbnail"]);
    yield videoThumbnails;
  }

  @override
  Widget build(BuildContext context) {
    // initState();
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
                                      icon: const Icon(Icons.delete ),
                                      onPressed: () async {
                                        // ボタンが押された際の動作を記述する
                                        final String? selectedText =
                                            await showDialog<String>(
                                                context: context,
                                                builder: (_) {
                                                  return SimpleDialogSample(
                                                      videoId[index]);
                                                });
                                          setState(() {
                                          });
                                      },
                                    )
                                  ],
                                )
                              ],
                            );
                          }))),
            ],
          );
        } else {
          return Column(
            children: [
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

class SimpleDialogSample extends StatefulWidget {
  String videoId;
  SimpleDialogSample(this.videoId, {Key? key}) : super(key: key);

  @override
  State<SimpleDialogSample> createState() => _SimpleDialogSampleState();
}

class _SimpleDialogSampleState extends State<SimpleDialogSample> {
  // アカウント削除
  void deleteNeta(String videoId) async {
    FirebaseFirestore.instance.collection("T05_Toukou").doc(videoId).delete();
    print('ボタンが押されました!');
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('　　ネタ動画削除'),
      children: [
        const Text("          本当にネタを削除しますか"),
        SimpleDialogOption(
          child: const Text('削除'),
          onPressed: () async {
            deleteNeta(widget.videoId);
            Navigator.pop(context);
            print('ネタを削除しました!');
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
