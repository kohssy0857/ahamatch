import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';

import '../parts/header.dart';

import '../functions.dart';
import '../parts/MoviePlayerWidget .dart';
import 'package:firebase_storage/firebase_storage.dart';

//
import '../homeTab/shinmeTab.dart';
import '../parts/FullscreenVideo.dart';
// void senddNeta() {}

class netaResult extends StatefulWidget {
  netaResult({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _netaResultState createState() => _netaResultState();
}

class _netaResultState extends State<netaResult> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoUrls = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];

  Stream<List> getVideo() async* {
    // ---------------------------------------------------------------
//       final ref =  FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
//       // 自身がフォローしている相手のidを取得
//       await FirebaseFirestore.instance.collection('T01_Person').doc(user!.uid).collection("Follow").get().
//     then((QuerySnapshot snapshot) async  {
//       if(snapshot.docs.isNotEmpty){
//         snapshot.docs.forEach((doc) {
//      documentList.add(doc.get('T05_GeininId'));
//    });
//   }

// });

//       if(documentList.isNotEmpty==true){
//         // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
//       await FirebaseFirestore.instance.collection('T05_Toukou').where("T05_Geinin", whereIn: documentList).get().
//     then((QuerySnapshot snapshot) {
//    snapshot.docs.forEach((doc) {
//     if(doc["T05_Type"]==1){
//       videoUrls.add(doc["T05_VideoUrl"]);
//     }
//    });
// });

//       final all = await  FirebaseStorage.instance.ref().child('post/neta/').listAll();

//       yield videoUrls;
//       }

      // 取得した動画URLのリストを
          // var url = await ref.getDownloadURL();
          // videoUrls.add(ref.toString());
          
          final ref = await FirebaseFirestore.instance.collection('T05_Toukou').doc("NVtS0y9o3JB0zjUwLPvv").get();
          // print(ref.data()!["T05_VideoUrl"]);
          videoUrls.add(ref.data()!["T05_VideoUrl"]);
          yield videoUrls;
}


    // 取得した動画URLのリストを
    // var url = await ref.getDownloadURL();
    // videoUrls.add(ref.toString());

    final ref = await FirebaseFirestore.instance
        .collection('T05_Toukou')
        .doc("NVtS0y9o3JB0zjUwLPvv")
        .get();
    // print(ref.data()!["T05_VideoUrl"]);
    videoUrls.add(ref.data()!["T05_VideoUrl"]);
    yield videoUrls;
  }

  @override
  Widget build(BuildContext context) {

        return 
          // Text("Left"),
          StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("ネタないよ");
                    }else if (snapshot.hasData){
                      List photo = snapshot.data!;
          print(snapshot);
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
                                        child: 
                                        MoviePlayerWidget(photo[index],"NVtS0y9o3JB0zjUwLPvv")
                                        // ElevatedButton(
                                        //   onPressed: () async {
                                        //     try {
                                        //       await Navigator.of(context).pushReplacement(
                                        //           MaterialPageRoute(builder: (context) {
                                        //             return FullscreenVideo();
                                        //           }),
                                        //         );
                                        //     } catch (e) {}
                                        //   }, child: Text("遷移"),
                                        // ),
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
                    },
                );
          // bottomNavigationBar: Footer(),
        
    }

  }
}
