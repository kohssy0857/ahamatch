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

class sendAhaPuch extends StatefulWidget {
  @override
  _sendAhaPuchState createState() => _sendAhaPuchState();
}

class _sendAhaPuchState extends State<sendAhaPuch> {
  final user = FirebaseAuth.instance.currentUser;
  String title = "";
  String shoukai = "";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  // 入力された内容を保持するコントローラ
  // final inputController = TextEditingController();
  VideoPlayerController? MovieController = null;
  File? movie = null;
  dynamic movie_file;
  // 画像アップロードに必要な物
  final picker = ImagePicker();
  File? imageFile;

  Future pickImage() async{
    final pickerFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
        if(pickerFile != null){
          imageFile = File(pickerFile.path);
          MovieController = await VideoPlayerController.file(imageFile!)
      ..initialize().then((_) async {

        // print("444444444444444444444444444444${MovieController!.value}");
        setState(() {});
        // print("dddddddddddddddddddddddddddddddddddddddddddddddd" +
        //     MovieController.toString());
        await MovieController?.play();
        // print("00000000000000000000000");

      });
        }
  }
  

  // title,,
  void _upload(String title, String shoukai) async {

    String? video;
    String? documentId;

    String? unitName;

    final doc = FirebaseFirestore.instance
        .collection('T05_Toukou').doc();


    final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);


      await FirebaseFirestore.instance
        .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
      (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach(
            (doc) {
              documentId=doc.id;

              unitName=doc["T02_UnitName"];

            },
          ),
        });
        // print("idは本当に入っているのか？？");
        // print(documentId);

      final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);

    if(imageFile != null){
      // storageにアップロード
      final task = await FirebaseStorage.instance
        .ref("post/ahapuchi/${doc.id}.mp4")
        .putFile(imageFile!);
      video = await task.ref.getDownloadURL();
    }

    // 紹介文、視聴回数は0
    await doc.set({
      'T05_Geinin': id,
      'T05_Title': title,
      "T05_Create": Timestamp.fromDate(DateTime.now()),
      "T05_VideoUrl": video,
      "T05_Type": 2,
      "T05_Shoukai": shoukai,
      "T05_ShityouKaisu": 0,

      "T05_UnitName": unitName,

    });
    print("登録できました");
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 200,
            height: 200,
            child: imageFile == null
                  ? const Text('No video selected.')
                  : AspectRatio(
                      aspectRatio: MovieController!.value.aspectRatio,
                      child: VideoPlayer(MovieController!),
                    )
          ),
          // OutlinedButton(
          //     onPressed: (() async => pickImage()), child: const Text("動画を選択")),
          // Column1
          Container(
              alignment: Alignment.center,
              child: Container(
                width: 300,
                height: 100,
                child:SizedBox(
              width:200,
              height: 30,
              child:ElevatedButton(
                  onPressed: () async {
                    await pickImage();
                    
                  },

                  child: Text('アハプッチ動画を選択'),

                ),
            ),
              ),
              
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(

                  maxLength: 50,

                  decoration: const InputDecoration(labelText: "動画タイトル"),
                  onChanged: (value) {
                    title = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(

                  maxLength: 50,

                  decoration: const InputDecoration(labelText: "紹介文"),
                  onChanged: (value) {
                    shoukai = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
          // Column2
          // Column3
          // Text(inputText),
          ElevatedButton(
              onPressed: () async {
                // _tachikame();

                if (_formKey.currentState!.validate() && imageFile != null) {
                      print("登録完了");
                      _upload(title, shoukai);
                try {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => App()));
                } catch (e) {}
                } else if (imageFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('アハプッチ動画を選択してください'),
                  ),
                );
              }
                

              },
              child: const Text('投稿'),
            ),
        ],
      ),
    );
  }
}

