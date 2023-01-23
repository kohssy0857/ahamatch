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
import 'convention_list.dart';
import 'convention_overview.dart';
import 'audition_overview.dart';
import 'audition_list.dart';


class MainModel extends ChangeNotifier {
  // ListView.builderで使うためのBookのList booksを用意しておく。
  List<Convention> events = [];

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
    print('len = ' + events.length.toString());
    notifyListeners();
  }
}

class Events extends StatelessWidget {
  const Events({Key? key}) : super(key: key);
  

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
    bool flag = true;
    return DefaultTabController(
      initialIndex: 0, // 最初に表示するタブ
      length: 2, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('イベント一覧'),
          bottom: const TabBar(
            isScrollable: true, // スクロールを有効化
            tabs: <Widget>[
              Tab(text: '大会'),
              Tab(text: 'オーディション'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            MaterialApp(
              home: ChangeNotifierProvider<MainModel>(
                // createでfetchBooks()も呼び出すようにしておく。
                create: (_) => MainModel()..fetchConventions(),
                child: Scaffold(
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
                                                  ConOverview(events, index)));
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
            ),
            Auditions(),
          ],
        ),
      ),
    );
  }
}
