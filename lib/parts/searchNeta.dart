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
import '../parts/SearchResult.dart';
import 'package:firebase_storage/firebase_storage.dart';

class searchNeta extends StatefulWidget {
  searchNeta({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _searchNetaState createState() => _searchNetaState();
}

class _searchNetaState extends State<searchNeta> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoUrls = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];

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
    if(doc["T05_Type"]==1){
      videoUrls.add(doc["T05_VideoUrl"]);
    }
   });
});
      final all = await  FirebaseStorage.instance.ref().child('post/neta/').listAll();
      yield videoUrls;
      }
      

      // 取得した動画URLのリストを
          // var url = await ref.getDownloadURL();
          
}

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          body: 
          // Text("Left"),
          StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("ネタないよ");
                    }else if (snapshot.hasData){
                      List photo = snapshot.data!;
                          return Column(
                            children: [
                              Text("ログイン情報:${user!.displayName}"),
                              Expanded(
                                  child:SizedBox(
                                      height: 250,
                                        width: 250,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                      // padding: EdgeInsets.all(250),
                                    itemCount: videoUrls.length,
                                    itemBuilder: (context, index){
                                      return SizedBox(
                                        height: 500,
                                        width: 250,
                                        child: MoviePlayerWidget(photo[index]),
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
                          Text("ログイン情報:${user!.displayName}"),
                          Text("芸人をフォローしてください"),
                        ],
                      );
                      // return const Text("not photo");
                    }
                    },),
            floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const uploadPost()));
              /* --- 省略 --- */
            },
          ),
          // bottomNavigationBar: Footer(),
        );
    }
  }

