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
import '../parts/header.dart';
import 'FullMoviePlayerWidget.dart';

class FullscreenVideo extends StatefulWidget {
  String movieId;
  double movieHeight;
  double movieWidth;
  // FullscreenVideo({Key? key,required this.movieId}) : super(key: key);
  FullscreenVideo(this.movieId, this.movieHeight, this.movieWidth) : super();
  @override
  _FullscreenVideoState createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<FullscreenVideo> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> bosyuList = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouDocId = [];
  List videoUrls = [];

  Stream<List> getVideo() async* {
    // print("wwwwwwwwwwwwwwwwwwwwwww");
    // print(widget.movieId);
    final ref = await FirebaseFirestore.instance
        .collection('T05_Toukou')
        .doc(widget.movieId)
        .get();
    // print(ref.data()!["T05_VideoUrl"]);
    videoUrls.add(ref.data()!["T05_VideoUrl"]);
    yield videoUrls;
  }

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    print("画面のサイズーーーーー");
    print(size.height);
    print(size.width);

    return Scaffold(
      appBar: const Header(),
      body:
          // Center(
          //   child: Text("あいうえお"),
          //   )
          StreamBuilder(
        stream: getVideo(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("ネタないよ");
          } else if (snapshot.hasData) {
            List photo = snapshot.data!;
            // if(widget.movieHeight>widget.movieWidth){
            //     return Column(
            //         children: [
            //           Text("ログイン情報:${user!.displayName}"),
            //           Expanded(
            //               child:SizedBox(
            //                   height: size.height/2,
            //                     width: size.width/2,
            //                     child: FullMoviePlayerWidget(photo[0],widget.movieId),
            //               )
            //           ),
            //             ],
            //           );
            // }else{
            return Column(
              children: [
                Expanded(
                    child: FullMoviePlayerWidget(photo[0], widget.movieId)),
              ],
            );
            // };

          } else {
            return Column(
              children: const [
                Text("芸人をフォローしてください"),
              ],
            );
            // return const Text("not photo");
          }
        },
      ),
    );
  }
}
