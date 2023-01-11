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
import '../parts/MoviePlayerWidget .dart';

class AnnounceResult extends StatefulWidget {
  AnnounceResult({Key? key}) : super(key: key);
  @override
  _AnnounceResultState createState() => _AnnounceResultState();
}

class _AnnounceResultState extends State<AnnounceResult> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> announceList = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];
  List unitNameList = [];

    Stream<List> getVideo() async* {
      // final ref =  FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
      // 自身がフォローしている相手のidを取得
      await FirebaseFirestore.instance.collection('T01_Person').doc(user!.uid).collection("Follow").get().
    then((QuerySnapshot snapshot) async  {
      if(snapshot.docs.isNotEmpty){
        snapshot.docs.forEach((doc) {
     documentList.add(doc.get('T05_GeininId'));
   });
  }
   
});

      if(documentList.isNotEmpty==true){
        // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
      await FirebaseFirestore.instance.collection('T05_Toukou').where("T05_Geinin", whereIn: documentList).get().
    then((QuerySnapshot snapshot) {
   snapshot.docs.forEach((doc) {
    if(doc["T05_Type"]==4){
      announceList.add(doc["T05_Announce"]);
      unitNameList.add(doc["T05_UnitName"]);
    }
   });
});

      final all = await  FirebaseStorage.instance.ref().child('post/neta/').listAll();
      yield announceList;
      }
      

      // 取得した動画URLのリストを
          // var url = await ref.getDownloadURL();
          
}

  Widget build(BuildContext context) {
    return 
    StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("告知ないよ");
                    }else if (snapshot.hasData){
                      List photo = snapshot.data!;
                          return Column(
                            children: [
                              ListView.builder(
                                        shrinkWrap: true,
                                      // padding: EdgeInsets.all(250),
                                    itemCount: announceList.length,
                                    itemBuilder: (context, index){
                                      return  Card(
                                          child: ListTile(
                                            // leading: Image.network(T02_Convention[index].T06_image),
                                            title: Text("告知内容："+announceList[index]),
                                            subtitle: Text("芸名："+unitNameList[index]), // 商品名
                                          ),
                                        );
                                      
                                    }
                                      )
                            ],
                          );
                    } else {
                      return Column(
                        children: [
                          Text("ログイン情報:${user!.displayName}"),
                          Text("芸人をフォローしてください"),
                        ],
                      );
                      // return const Text("not photo");
                    }
                    },);
  }
}

