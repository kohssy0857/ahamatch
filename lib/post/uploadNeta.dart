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
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class sendNeta extends StatefulWidget {
  @override
  _sendNetaState createState() => _sendNetaState();
}

class _sendNetaState extends State<sendNeta> {
  final user = FirebaseAuth.instance.currentUser;
  String title = "";
  String shoukai = "";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  int i = 0;
  // 入力された内容を保持するコントローラ

  List<String> list = ["大会選択なし"];
  String dropdownValue = "大会選択なし";

  // final inputController = TextEditingController();
  VideoPlayerController? MovieController = null;
  File? movie = null;
  dynamic movie_file;
  // 画像アップロードに必要な物
  final picker = ImagePicker();
  File? imageFile;

  String? _uint8list;

  // 画像の選択
  Future pickImage() async{
    final pickerFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickerFile != null) {
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

  Future<List<String>> getName() async {
    await FirebaseFirestore.instance
        .collection('T04_Event')
        .doc("cvabc8IsVAGQjYwPv0fR")
        .collection('T02_Convention')
        .where("T07_flag", isEqualTo: 1)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        list.add(doc["T05_Name"]);
      });
    });
    list = list.toSet().toList();
    return list;
  }

  // title,,
  void _upload(String title, String shoukai, String value) async {
    String video="";
    String? documentId;
    String? unitName;
    String thumbnail = "";
    String conid = "";
    List idList = [];
    
    final doc = FirebaseFirestore.instance.collection('T05_Toukou').doc();
    final gid =
        FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid);
    final con = FirebaseFirestore.instance.collection('T07_Convention').doc();
    // print("gidってなにーー？？");
    // print(gid);
    // print(gid.runtimeType);

    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where('T02_GeininId', isEqualTo: gid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach(
                (doc) {
                  documentId = doc.id;
                  unitName = doc["T02_UnitName"];
                },
              ),
            });
    
    await FirebaseFirestore.instance
        .collection('T04_Event')
        .doc('cvabc8IsVAGQjYwPv0fR')
        .collection('T02_Convention')
        .where("T07_flag", isEqualTo: 1)
        .where("T05_Name", isEqualTo: value)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        conid = doc["T08_DocumentId"];
      });
    });
    // print("idは本当に入っているのか？？");
    // print(documentId);

    final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);

    if (imageFile != null) {
      // storageにアップロード
      final task = await FirebaseStorage.instance
          .ref("post/neta/${doc.id}.mp4")
          .putFile(imageFile!);
      video = await task.ref.getDownloadURL();
      final _uint8list = await VideoThumbnail.thumbnailFile(
      video: video,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    final task2=await FirebaseStorage.instance
        .ref("post/thumbnail/${doc.id}")
        .putFile(File(_uint8list!));
      thumbnail =await task2.ref.getDownloadURL();
    }
    // final _image = Image.memory(uint8list!);
    // print("画像ーーーーーーーーーーー");
    // print(_image);

    // 紹介文、視聴回数は0
    await doc.set({
      'T05_Geinin': id,
      'T05_Title': title,
      "T05_Create": Timestamp.fromDate(DateTime.now()),
      "T05_VideoUrl": video,
      "T05_Type": 1,
      "T05_Shoukai": shoukai,
      "T05_ShityouKaisu": 0,
      "T05_UnitName": unitName,
      "T05_Thumbnail":thumbnail,
    });

    // await FirebaseFirestore.instance
    //   .collection("T04_Event")
    //   .doc("cvabc8IsVAGQjYwPv0fR")
    //   .collection("T02_Convention")
    //   .doc(conid)
    //   .collection("Vote_Name")
    //   .where("PersonId", isEqualTo: user!.uid)
    //   .get()
    //   .then((QuerySnapshot snapshot) {
    //   snapshot.docs.forEach((doc) {
    //     idList.add(doc["PersonId"]);
    //   });
    // });

    if (value == '大会選択なし') {
      print('ok');
    } else if (idList.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('大会にネタを投稿できませんでした'),
        ),
      );
    } else {
      await con.set({
        'T07_Geinin': id,
        'T07_VideoUrl': video,
        'T07_votes': 0,
        'T07_Create': Timestamp.fromDate(DateTime.now()),
        'T07_ConventionId': conid,
      });

    final ref = await FirebaseFirestore.instance
      .collection("T04_Event")
      .doc("cvabc8IsVAGQjYwPv0fR")
      .collection("T02_Convention")
      .doc(conid)
      .collection("Vote_Name")
      .doc();

      await ref.set({
        "PersonId": FirebaseAuth.instance.currentUser!.uid,
      });

    }
    print("登録できました");
  }

  @override
  Widget build(BuildContext context) {
    getName().then((value) {
      if (i == 0) {
        setState(() {
          dropdownValue = value.first;
          i++;
        });
      }
    });
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
                    )),
          // OutlinedButton(
          //     onPressed: (() async => pickImage()), child: const Text("動画を選択")),
          // Column1
          Container(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              height: 100,
              child: SizedBox(
                width: 200,
                height: 30,
                child: ElevatedButton(
                  onPressed: () async {
                    await pickImage();
                  },
                  child: Text('ネタ動画を選択'),
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

          DropdownButton<String>(
            value: dropdownValue,
            elevation: 16,
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          ElevatedButton(

            onPressed: () async {
              // _tachikame();
              if (_formKey.currentState!.validate() && imageFile != null) {
                print("登録完了");
                _upload(title, shoukai, dropdownValue);
                try {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => App()));
                } catch (e) {
                  print(e);
                }
              } else if (imageFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ネタ動画を選択してください'),
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
