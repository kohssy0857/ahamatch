import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/cupertino.dart';
import '../functions.dart';
import 'package:provider/provider.dart';
import 'convention_overview.dart';
import 'events_list.dart';


  List geininId = [];
  List<String> list = [];
class MainModel extends ChangeNotifier {
  // ListView.builderで使うためのBookのList booksを用意しておく。
  List<Convention> events = [];
  DateTime now = DateTime.now();

  Future<void> fetchConventions() async {
    // Firestoreからコレクション'books'(QuerySnapshot)を取得してdocsに代入。
    // final docs = await FirebaseFirestore.instance.collection('books').get();
    final event = await FirebaseFirestore.instance
        .collection('T04_Event')
        .doc("cvabc8IsVAGQjYwPv0fR")
        .collection('T02_Convention')
        .where('T07_flag', isEqualTo: 1)
        .get();
    final events = event.docs.map((doc) => Convention(doc)).toList();

    DateTime now = DateTime.now();
      for (int i = 0; i < events.length; i++) {
        DateTime schedule = events[i].schedule.toDate();
        if (schedule.isBefore(now)) {
          final doc = FirebaseFirestore.instance
            .collection('T04_Event')
            .doc("cvabc8IsVAGQjYwPv0fR")
            .collection('T02_Convention')
            .doc(events[i].docid);
          
          await doc.update({
            "T07_flag": 0,
          });

          events.removeAt(i);
        }
      }

    this.events = events;

for(int i = 0; i < events.length; i++) {
      await FirebaseFirestore.instance
          .collection("T07_Convention")
          .where("T07_Convention", isEqualTo: events[i].docid)
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) {
          geininId.add(doc["T07_Geinin"]);
        });
      });
    }
    await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .where("T02_GininId", whereIn: geininId)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        list.add(doc["T02_UnitName"]);
      });
    });


    print('len = ' + events.length.toString());
    notifyListeners();
  }
}

class Conventions extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  late Image img;
  int i = 0;
  bool flag = false;

  final docs = FirebaseFirestore.instance
      .collection('T04_Event') // コレクションID
      .doc("cvabc8IsVAGQjYwPv0fR")
      .collection('T02_Convention')
      .doc();

  Stream<Image> getAvatarUrlForProfile(
      List<Convention> events, int index) async* {
    // final ref =
    //     FirebaseStorage.instance.ref().child('convention/${docs.id}.jpg');
    // print('ref =${docs.id}');
    // no need of the file extension, the name will do fine.
    // var url = await ref.getDownloadURL();
    var url = events[index].url;
    print('url = ${events[index].url}');

    yield Image.network(
      url,
      height: 100,
      width: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<MainModel>(
        // createでfetchBooks()も呼び出すようにしておく。
        create: (_) => MainModel()..fetchConventions(),
        child: Scaffold(
          // appBar: const Header(),
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              final events = model.events;
              if (events.isEmpty) {
                return const Text("大会は現在開催されていません。");
              } else {
                return Container(
                  // height: 500,
                  padding: EdgeInsets.all(2),
                  // 各アイテムの間にスペースなどを挟みたい場合
                  child: ListView.separated(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            StreamBuilder(
                              stream: getAvatarUrlForProfile(events, index),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("wait");
                                } else if (snapshot.hasData) {
                                  Image photo = snapshot.data!;
                                  return photo;
                                } else {
                                  return const Text("not photo");
                                }
                              },
                            ),
                            SizedBox(
                              width: 75.0,
                            ),
                            Container(
                              height: 50,
                              // color: books[index]['color'],
                              child: Text(
                                events[index].name,
                                // style: TextStyle(fontSize: ),
                              ),
                            ),
                            SizedBox(
                              width: 75.0,
                            ),
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                print('model = ${model}');
                                print('events = ${events}');
                                Navigator.push(
                                    // ボタン押下でオーディション編集画面に遷移する
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConOverview(model: events, index: index)));
                                // AlertDialog(
                                //   title: Text('大会名：${}'),);
                              },
                            ),
                          ],
                        );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class Convention {
  // Conventionで扱うフィールドを定義しておく。
  String name = "";
  String condition = "";
  Timestamp schedule = Timestamp(2020, 10);
  String prize = "";
  String url = "";
  int flag = 1;
  String docid = "";

  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  Convention(DocumentSnapshot doc) {
    //　ドキュメントの持っているフィールド'T05_Name'をこのConventionのフィールドnameに代入
    name = doc['T05_Name'];
    condition = doc['T01_Conditions'];
    schedule = doc['T02_Schedule'];
    prize = doc['T03_Prize'];
    url = doc['T06_image'];
    flag = doc['T07_flag'];
    docid = doc['T08_DocumentId'];
  }
}
