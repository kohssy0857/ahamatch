import 'dart:developer';

import 'package:ahamatch/home/SysHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../home/SearchResult.dart';
import '../login/loginFollow.dart';
import '../functions.dart';

class geininFollowProfile extends StatefulWidget {
  // AuditionManagement画面にあるmodelを取得している
  final model;
  // AuditionManagement画面にあるそれぞれのindex番号を取得している
  final int index;

  String UnitName = "";
  DocumentReference<Map<String, dynamic>> GeininId;

  String PersonId ="";

  geininFollowProfile(this.model,this.index,this.GeininId){
      UnitName = model.T02_Geinin[index].T02_UnitName;
      print("ojojoojo");
      print(GeininId);
      // print(GeininId.path.replaceFirst("T01_Person/", ""));
      PersonId = GeininId.path.replaceFirst("T01_Person/", "");
      // GeininId = model.T02_Geinin[index];
  }
  
  // const AuditionEdit({Key? key, this.T01_Audition}) : super(key: key);
  
  @override
  _geininFollowProfile createState() => _geininFollowProfile();
}




class _geininFollowProfile extends State<geininFollowProfile> {
  
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  String? documentId;
  String? OkuruDocumentId;
  String? followDocumentId;
  bool isFollwing = false;
  int count = 0;

  Future _followKakunin() async{
    // print("確認だよ");
    final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(widget.PersonId);
        print("ttttttttttttttttttttttttttt");
        print(gid);
      await FirebaseFirestore.instance
        .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
      (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach(
            (doc) {
              documentId=doc.id;
            },
          ),
        });
      // 今表示している芸人のid=/T02_Geinin/documentIdのリファレンスを確保
      final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);
      // 自分のフォローコレクションの中に、今表示している芸人が存在するかどうかの確認
      final followcheck = FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid).collection("Follow").where('T05_GeininId', isEqualTo: id);
      followcheck.get()
      .then((docSnapshot) async => {
        // 存在しない場合、フォローを行う
        if (docSnapshot.docs.isEmpty) {
          // print("ないよ"),
          // print("isFollwingだよ"),
          // print(isFollwing),
        // 存在する場合、フォローを行う
        } else {
         isFollwing = true,
          // print("isFollwingだよ"),
          // print(isFollwing),
          if(count==0){
            setState(() {
              count++;
                }),
          }
              
        }
    });

      }

    Future _Follow() async {
    String userid = "";
    final docRef = FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid).collection("Follow").doc();
    // print("何個あるんでルカ----------");
    // print(docRef3);
    final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(widget.PersonId);
    // print("gidってなにーー？？");
    // print(gid);
    // print(gid.runtimeType);
    // 今表示している芸人のドキュメントIDを確保
      await FirebaseFirestore.instance
        .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
      (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach(
            (doc) {
              documentId=doc.id;
            },
          ),
        });

      

      
      // 今表示している芸人のid=/T02_Geinin/documentIdのリファレンスを確保
      final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);

       

      // 自分のフォローコレクションの中に、今表示している芸人が存在するかどうかの確認
      final followcheck = FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid).collection("Follow").where('T05_GeininId', isEqualTo: id);
      followcheck.get()
  .then((docSnapshot) async => {
    // 存在しない場合、フォローを行う
    if (docSnapshot.docs.isEmpty) {
      // print("ないよ"),
      await docRef.set({
      'T05_GeininId': id,
    }),
    await FirebaseFirestore.instance.collection('T02_Geinin').doc(documentId)
    .update({"T02_Follower": FieldValue.increment(1.0)}),
    setState(() {
      isFollwing = true;
                }),
    // 存在する場合、フォローを行う
    } else {
      // print("あるよ"),
      await followcheck.get().then(
      (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach(
            (doc) {
              followDocumentId=doc.id;
            },
          ),
        }),
      await FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid).collection("Follow").doc(followDocumentId).delete(),
      await FirebaseFirestore.instance.collection('T02_Geinin').doc(documentId)
    .update({"T02_Follower": FieldValue.increment(-1.0)}),
      setState(() {
        isFollwing = false;
                }),
    }
});

    
  }

  // 芸人のT02_GeininからT01_Personを繋ぎ、uidを取得する
  Stream<Image> getAvatarUrlForProfile() async* {
          final ref =  FirebaseStorage.instance.ref().child('profile/${widget.PersonId}.jpg');
      // no need of the file extension, the name will do fine.
          var url = await ref.getDownloadURL();
          yield Image.network(
          url,
          width: 300,
          height: 300,);
      }



  @override
    Widget build(BuildContext context) {
    _followKakunin();
    return Scaffold(
          appBar: Header(),
              body: Column( //RowとStackでも同じ
                children: <Widget>[
                  
                  Text('芸人名：${widget.UnitName}====2'),
                  // Text(img.toString()),
                  StreamBuilder(stream: getAvatarUrlForProfile(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("no photo");
                    }else if (snapshot.hasData){
                      Image photo = snapshot.data!;
                      return  photo;
                    } else {
                      return const Text("not photo");
                    }
                    },),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        _Follow();
                      } catch (e) {}
                    },
                    child: 
                    isFollwing ==false ?  Text('フォロー'): Text('フォロー解除'),
                  ),  
                ],
                
          ), 
        );
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}
