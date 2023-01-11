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



class mylist extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  File? imageFile;
  Future pickImage() async {
    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickerFile != null) {
      imageFile = File(pickerFile.path);
    }
  }

  // void _upload() async {
  //   String? T06_image;
  //   // final doc = FirebaseFirestore.instance
  //   //     .collection('T01_Person') // コレクションID
  //   //     .doc("cvabc8IsVAGQjYwPv0fR")
  //   //     .collection('T01_Audition')
  //   //     .doc();

  //   if (imageFile != null) {
  //     // storageにアップロード
  //     final task = await FirebaseStorage.instance
  //         .ref("post/shinme/${user!.uid}.mp4")
  //         .putFile(imageFile!);
  //     T06_image = await task.ref.getDownloadURL();
  //   }
  //   print("登録できました");
  // }

  // storegeの中の動画を取得してくる
void _getVideo() async {
    String? T06_image;

    if (imageFile != null) {
      // storageにアップロード
      final task = await FirebaseStorage.instance
          .ref("post/shinme/マルセロ1.mp4")
          .putFile(imageFile!);
      T06_image = await task.ref.getDownloadURL();
    }
    print("登録できました");
  }

      Stream<MoviePlayerWidget> getVideo() async* {
      final ref =  FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
      final all = await  FirebaseStorage.instance.ref().child('post/shinme/').listAll();
      // for (var prefix in all.prefixes) {
      //   print("prefixはどこにいったんだいーーーーー！！！！！！！！！！！！！！！？？？？？？？？？？？？？？？？？");
      //   print(prefix);
      //   // The prefixes under storageRef.
      //   // You can call listAll() recursively on them.
      // }
      // for (var item in listResult.items) {
      //   // The items under storageRef.
      // }
      // no need of the file extension, the name will do fine.
          var url = await ref.getDownloadURL();
          yield MoviePlayerWidget(
            url,""
          );
      }
      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(),
        // body: Form(
        //   key: _formKey,
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     SizedBox(
        //       width: 200,
        //       height: 30,
        //       child: imageFile != null
        //           ? Image.file(imageFile!)
        //           : ElevatedButton(
        //               onPressed: () async {
        //                 await pickImage();
        //               },
        //               child: Text('オーディション画像選択'),
        //             ),
        //     ),
        //     const SizedBox(
        //       height: 40.0,
        //     ),
        //     ElevatedButton(
        //       onPressed: () async {
        //         _upload();
        //       },
        //       child: const Text('登録'),
        //     ),
        //   ],
        // ),
        // )
      
              body: Column( //RowとStackでも同じ
                children: [
                  Text('プロフィール名：${user!.displayName}====2'),
                  Text('マイリストの画面だよ！！！！！！！！！'),
                    StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("no photo");
                    }else if (snapshot.hasData){
                      MoviePlayerWidget photo = snapshot.data!;
                      return  SizedBox(
                        width: 300,
                        height: 300,
                        child:photo
                      );
                      
                    } else {
                      return const Text("not photo");
                    }
                    },)
                ],
                
          ),
          
          // body: Center(
          //   child:StreamBuilder(img?, builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  },)
          // ),
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.add),
          //   onPressed: () async {
          //     await FirebaseAuth.instance.signOut();
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => UserLogin()));
          //     /* --- 省略 --- */
          //   },
          // ),
          // bottomNavigationBar: Footer(),
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
