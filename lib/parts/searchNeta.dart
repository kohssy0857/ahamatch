import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import 'footer.dart';

import 'header.dart';

import '../functions.dart';
import '../parts/MoviePlayerWidget .dart';
import 'Search.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  List<String> videoTitle = [];
  List<String> videoUrls = [];
  List<String> searchedNames = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];


  Stream<List> getVideo(String word) async* {
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
        videoTitle.add(doc["T05_Title"]);
      });
    });
    if (widget.word.trim().isEmpty) {
      searchedNames = [];
    } else {
      searchedNames =
          videoTitle.where((element) => element.contains(word)).toList();
    }
    // }
    if (searchedNames.isNotEmpty) {
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
              toukouList.add(doc.reference.id);
            });
          });
        }
    }
    yield videoUrls;

    // 取得した動画URLのリストを
    // var url = await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {


    return StreamBuilder(
      stream: getVideo(widget.word),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ネタないよ");
        } else if (snapshot.hasData && toukouList.isNotEmpty) {
          List photo = snapshot.data!;
          print(toukouList);
          return Column(
            children: [
              Text("ログイン情報:${user!.displayName}"),
              Expanded(
                  child: SizedBox(
                      height: 250,
                      width: 250,
                      child: ListView.builder(
                          shrinkWrap: true,
                          // padding: EdgeInsets.all(250),
                          itemCount: videoUrls.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 500,
                              width: 250,
                              child: MoviePlayerWidget(
                                  photo[index], toukouList[index]),
                            );
                          }))),
            ],
          );
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
