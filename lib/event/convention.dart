import 'package:ahamatch/event/convention_movie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';
import '../parts/header.dart';
import '../functions.dart';
import 'package:provider/provider.dart';
import 'convention_list.dart';
import 'audition_overview.dart';
import 'audition_list.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

List videourl = [];
List list = [];

class Con extends StatefulWidget {
  Con({Key? key}) : super(key: key);
  @override
  _Con createState() => _Con();
}

class _Con extends State<Con> {
  List<Convention> events = [];

  Stream<List> fetchConventions() async* {
    // Firestoreからコレクション'Convention'(QuerySnapshot)を取得してeventに代入。
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
    if (events.isNotEmpty) {
      for (int i = 0; i < events.length; i++) {
        await FirebaseFirestore.instance
            .collection("T07_Convention")
            .where("T07_ConventionId", isEqualTo: events[i].docid)
            .get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((doc) {
            videourl.add(doc["T07_VideoUrl"]);
          });
        });
      }
      yield videourl;
    }
  }

  Stream<List> getAvatarUrlForProfile(List<Convention> events) async* {
    for (int i = 0; i < events.length; i++) {
      await FirebaseFirestore.instance
          .collection("T07_Convention")
          .where("T07_ConventionId", isEqualTo: events[i].docid)
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) {
          videourl.add(doc["T07_VideoUrl"]);
        });
      });
    }
    yield videourl;
  }

  AlertDialogSample(index) {
    initializeDateFormatting('ja');
    showDialog(
      context:  context,
      builder: (context) => AlertDialog(
        title: Text('大会名：${events[index].name}'),
        content: Container(
          width: 400,
          child: Text('大会概要\n' +
                '条件：${events[index].condition}\n' +
                '期限：' +
                DateFormat('yMMMEd', 'ja').format(events[index].schedule.toDate()) +
                '\n' +
                '賞品：${events[index].prize}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  fromAtNow(DateTime date) {
    final Duration difference = date.difference(DateTime.now());
    final int sec = difference.inSeconds;

    if (sec >= 60 * 60 * 24) {
      return
       Text('あと${difference.inDays.toString()}日');
    } else if (sec >= 60 * 60) {
      return Text('あと${difference.inHours.toString()}時間');
    } else {
      return Text('あと${difference.inMinutes.toString()}分');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
                      stream: fetchConventions(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("wait");
                        } else if (snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.all(2),
                            // 各アイテムの間にスペースなどを挟みたい場合
                            child: ListView.separated(
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  height: 100,
                                  child: ListTile(
                                    minVerticalPadding: 0,
                                    minLeadingWidth: 200,
                                    title: Text(events[index].name),
                                    subtitle: fromAtNow(events[index].schedule.toDate()),
                                    leading: Image.network(
                                      events[index].url,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.fill,
                                    ),
                                    trailing: IconButton(
                                    icon: const Icon(Icons.info),
                                      onPressed: () {
                                        // Navigator.push(
                                        //   // ボタン押下で大会詳細に遷移する
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //     ConOverview(model: events, index: index)
                                        //   )
                                        // );
                                        AlertDialogSample(index);

                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                            netaCon(events: events, index: index)
                                        )
                                      ).then((value) {});
                                    },
                                  )
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                            ),
                          );
                        } else {
                          return const Text("大会は開催されていません",style: TextStyle(fontSize: 30,));
                        }
                      },
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