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

  @override
  // void initState() {
  //     setState(() {
  //       getVideo();
  //     });
  //     super.initState();
  // }

  Stream<List> getVideo() async* {
    await FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid).collection("mylist").get()
    .then(
      (QuerySnapshot querySnapshot) => {
        if(querySnapshot.docs.isNotEmpty){
          querySnapshot.docs.forEach(
            (doc) async {
              // リアルタイムでfirebaseFirestoreからデータをもってくる
              //  print("あいだーーーーーーーーーーーーーーー11111111");
              FirebaseFirestore.instance.collection('T05_Toukou').doc(doc["movieId"]).snapshots().listen((DocumentSnapshot snapshot) {
              // print("あいだーーーーーーーーーーーーーーー2222");
              if(videoThumbnails.contains(snapshot.get('T05_Thumbnail'))==false){
                videoThumbnails.add(snapshot.get('T05_Thumbnail'));
                videoTitle.add(snapshot.get('T05_Title'));
                videoId.add(snapshot.id);
                print("サムネどこーーーーーーーーーーー");
                print(videoThumbnails);
              }
              });
            },
          ),
        }
        });
          if(videoThumbnails.length==0 && count<5){
          setState(() {
            count+=1;
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
        return 
          StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("ネタないよ");
                    }else if (snapshot.hasData){
                      List photo= snapshot.data!;
                          return Column(
                            children: [
                              Expanded(
                                  child:SizedBox(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                      // padding: EdgeInsets.all(250),
                                        itemCount: videoThumbnails.length,
                                        itemBuilder: (context, index){
                                          return Column(
                                            children: [
                                              Text("${videoTitle[index]}"),
                                              SizedBox(
                                                height: 200,
                                                width: 200,
                                            child: 
                                            Image.network(
                                              photo[index],
                                              width: 300,
                                              height: 300,),
                                          ),
                                          
                                          IconButton(
                                            onPressed: () async{
                                              Navigator.push(
                                                      context, MaterialPageRoute(builder: (context) => FullscreenVideo(videoId[index],100,99)))
                                                      .then((value) {
                                                // 再描画
                                                setState(() {});
                                              });;
                                            },
                                            icon: Icon(Icons.fullscreen),
                                          ),
                                            ],
                                          );
                                          
                                        }
                                      )
                                  )
                          ),
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
