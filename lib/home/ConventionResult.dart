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
import 'ConventionManagement.dart';

class ConventionResult extends StatefulWidget {
  // AuditionManagement画面にあるmodelを取得している
  final MainModel model;
  // AuditionManagement画面にあるそれぞれのindex番号を取得している
  final int index;
  // それぞれ入力してもらったデータを表示させるための準備
  // 入力したデータを格納するそれぞれの変数
  String ConventionName = "****";
  String conditions = "ちょめ";
  DateTime schedule = DateTime(2020, 10, 2, 12, 10);
  String prize = "ちゃめ放送";
  String? T06Image;

  ConventionResult({Key? key, required this.model, required this.index})
      : super(key: key);

  @override
  _ConventionResult createState() => _ConventionResult();
}

class _ConventionResult extends State<ConventionResult> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  List geininlist = [];
  List votelist = [];
  List list = [];
  List name = [];
  List idlist = [];
  bool i = true;
  String text = "";

  // 画像の取得に必要なもの
  final picker = ImagePicker();
  File? imageFile;
  Future pickImage() async {
    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickerFile != null) {
      imageFile = File(pickerFile.path);
    }
  }

  Stream<List> getMovieList() async* {
    await FirebaseFirestore.instance
        .collection("T07_Convention")
        .orderBy("T07_votes", descending: true)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc["T07_ConventionId"] ==
            widget.model.T02_Convention[widget.index].ID) {
          geininlist.add([
            doc["T07_Geinin"].path.replaceFirst("T02_Geinin/", ""),
            doc["T07_votes"]
          ]);
          votelist.add(doc["T07_votes"]);

          if (geininlist.isNotEmpty) {
            FirebaseFirestore.instance
                .collection("T02_Geinin")
                // .where("T07_ConventionId", isEqualTo: widget.model.T02_Convention[widget.index].ID)
                // .where("T07_votes", isEqualTo: votelist[0])
                .doc(
                    "${doc["T07_Geinin"].path.replaceFirst("T02_Geinin/", "")}")
                .get()
                .then((DocumentSnapshot snapshot) {
              list.add(snapshot.get("T02_UnitName"));
            });
          }
        }
      });
    });

    yield list;
  }

  ranking() {
    if (geininlist.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: ((context, index) {
          return SizedBox(
              height: 100,
              child: ListTile(
                minVerticalPadding: 0,
                minLeadingWidth: 100,
                title: Text("${name[index].padRight(200)}${votelist[index]}票"),
                leading: Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown,
                  ),
                  child: Text(
                    "${index + 1}位",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 24),
                  ),
                ),
              ));
        }),
      );
    } else {
      return Container();
    }
  }

  Future _upload(String text) async {
    await FirebaseFirestore.instance
        .collection("T01_Person")
        // .where('T01_kind', isNotEqualTo: 0)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        idlist.add(element.id);
      });
    });
    for (int j = 0; j < idlist.length; j++) {
      await FirebaseFirestore.instance
          .collection('T01_Person') // コレクションID
          .doc(idlist[j]) // ドキュメントID
          .collection('Notification')
          .doc()
          .set({
        'Create': Timestamp.fromDate(DateTime.now()),
        'Text': text,
        'unread': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('大会結果！！！！！！！！'),
            actions: i
                ? [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            i = false;
                          });
                        })
                  ]
                : []),
        body: StreamBuilder(
          stream: getMovieList(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("ロード中");
            } else if (snapshot.hasData) {
              print(snapshot);
              name = snapshot.data!;
              return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ranking(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: TextFormField(
                              maxLength: 50,
                              decoration: InputDecoration(labelText: "通知内容"),
                              onChanged: (value) {
                                text = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "必須です";
                                }
                                return null;
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // _tachikame();
                              if (_formKey.currentState!.validate()) {
                                await _upload(text);
                                print("登録完了");
                                try {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => App()));
                                } catch (e) {
                                  print(e);
                                }
                              }
                            },
                            child: const Text('投稿'),
                          ),
                        ]),
                  ));
            } else {
              return Container();
            }
          },
        ));
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}
