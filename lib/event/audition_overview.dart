import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../parts/MoviePlayerWidget .dart';
import '../firebase_options.dart';
import '../login/login.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'events_list.dart';
import '../functions.dart';
import 'audition_list.dart';
class AudiOverview extends StatefulWidget {
  final List<Audition> model;
  // AuditionManagement画面にあるそれぞれのindex番号を取得している
  final int index;
  AudiOverview(this.model, this.index);

  @override
  _AudiOverview createState() => _AudiOverview();
}


class _AudiOverview extends State<AudiOverview> {
  final user = FirebaseAuth.instance.currentUser;
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
        print("444444444444444444444444444444${MovieController!.value}");
        setState(() {});
        print("dddddddddddddddddddddddddddddddddddddddddddddddd" +
            MovieController.toString());
        await MovieController?.play();
        print("00000000000000000000000");
      });
        }
  }

  void _upload(String unitName, String oubo) async {
    String? video;
    String? documentId;

    final gid = await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);

    final doc = FirebaseFirestore.instance
        .collection('T04_Event') // コレクションID
        .doc("cvabc8IsVAGQjYwPv0fR")
        .collection('T01_Audition')
        .doc(widget.model[widget.index].docid)
        .collection('T01_Audition')
        .doc();
    
    await FirebaseFirestore.instance
        .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
      (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach(
            (doc) {
              documentId=doc.id;
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
        .ref("audition/${doc.id}.mp4")
        .putFile(imageFile!);
      video = await task.ref.getDownloadURL();
    }


    await doc.set({
      'T01_UnitName': unitName,
      "T02_Oubo": oubo,
      "T03_Create": Timestamp.fromDate(DateTime.now()),
      "T04_Geinin": id,
      "T05_VideoUrl": video,
    });
    print("登録できました");
  }

  Stream<Image> getAvatarUrlForProfile(List events, int index) async* {
    var url = events[index].url;
    print('url = ${events[index].url}');

    yield Image.network(
      url,
      height: 100,
      width: 100,
    );
  }

  String unitName = "";
  String oubo = "";


  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ja');
    DateTime schedule = widget.model[widget.index].schedule.toDate();
    return Scaffold(
      appBar: const Header(),
      body: SingleChildScrollView(
        // ユーザー情報を表示
        child: Column(
          
        mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Container(
            // height: 50,
            child: Text('オーディション名：${widget.model[widget.index].name}'),
          ),
          Divider(),
          Container(
            height: 100,
            child: Text(
                'オーディション概要\n' + '会社名：${widget.model[widget.index].company}\n'),
          ),
          StreamBuilder(
            stream: getAvatarUrlForProfile(widget.model, widget.index),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("wait");
              } else if (snapshot.hasData) {
                Image photo = snapshot.data!;
                return photo;
              } else {
                return const Text("not photo");
              }
            },
          ),
          Text('オーディション名：${widget.model[widget.index].name}'),
          const Divider(),
          Container(
            child: Text('期限：' +
                DateFormat('yMMMEd', 'ja').format(schedule) +
                '\n募集要項：${widget.model[widget.index].item}'),
          ),
          const Divider(),
          Text('投稿フォーム'),
          const Divider(),
          SizedBox(
            width: 200,
            height: 200,
              child: imageFile == null
                  ? const Text('No image selected.')
                  : AspectRatio(
                      aspectRatio: MovieController!.value.aspectRatio,
                      child: VideoPlayer(MovieController!),
                    )),
          OutlinedButton(
              onPressed: () async {
                await pickImage();
              },
              child: const Text("動画を選択")),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: TextFormField(
                decoration: const InputDecoration(labelText: "ユニット名"),
                onChanged: (value) {
                    unitName = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: TextFormField(
                decoration: const InputDecoration(labelText: "応募文"),
                onChanged: (value) {
                    oubo = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "必須です";
                  }
                  return null;
                },
              )),
              ElevatedButton(
                onPressed: () async {
                // _upload(unitName, oubo);
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('オーディションに動画を投稿しました。'),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {}
                },
                child: const Text('投稿'),
              ),
        ]),
      ),
    );
  }
}

