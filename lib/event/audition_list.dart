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
import 'audition_overview.dart';

class MainModel extends ChangeNotifier {
  // ListView.builderで使うためのBookのList booksを用意しておく。
  List<Audition> auditions = [];
  DateTime now = DateTime.now();

  Stream<List> fetchEvents() async* {
    // Firestoreからコレクション'books'(QuerySnapshot)を取得してdocsに代入。
    final docs_audi = await FirebaseFirestore.instance
        .collection('T04_Event')
        .doc('cvabc8IsVAGQjYwPv0fR')
        .collection('T01_Audition')
        .where("T08_flag", isEqualTo: 1)
        .get();
    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をBookに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final auditions = docs_audi.docs.map((doc) => Audition(doc)).toList();

     DateTime now = DateTime.now();
    for (int i = 0; i < auditions.length; i++) {
      DateTime schedule = auditions[i].schedule.toDate();
      if (schedule.isBefore(now)) {
        final doc = FirebaseFirestore.instance
            .collection('T04_Event')
            .doc("cvabc8IsVAGQjYwPv0fR")
            .collection('T01_Audition')
            .doc(auditions[i].docid);

        await doc.update({
          "T08_flag": 0,
        });
        auditions.removeAt(i);
      }
    }
    this.auditions = auditions;
    // for (var i = 0; i >= auditions.length; i ++) {
    //   if(now.isBefore(auditions[i].schedule.toDate())) {

    //   }
    // }
    print('len = ' + auditions.length.toString());
    notifyListeners();
  }
}

class Auditions extends StatefulWidget {
  Auditions({Key? key}) : super(key: key);
  @override
  _Auditions createState() => _Auditions();
}

class _Auditions extends State<Auditions> {
  User? user = FirebaseAuth.instance.currentUser;
  late Image img;
  int i = 0;
  List<Audition> auditions = [];
  DateTime now = DateTime.now();
  final docs = FirebaseFirestore.instance
      .collection('T04_Event') // コレクションID
      .doc("cvabc8IsVAGQjYwPv0fR")
      .collection('T02_Convention')
      .doc();

  Stream<List> fetchEvents() async* {
    // Firestoreからコレクション'books'(QuerySnapshot)を取得してdocsに代入。
    final docs_audi = await FirebaseFirestore.instance
        .collection('T04_Event')
        .doc('cvabc8IsVAGQjYwPv0fR')
        .collection('T01_Audition')
        .where("T08_flag", isEqualTo: 1)
        .get();
    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をBookに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final auditions = docs_audi.docs.map((doc) => Audition(doc)).toList();

    for (int i = 0; i < auditions.length; i++) {
      DateTime schedule = auditions[i].schedule.toDate();
      if (schedule.isBefore(now)) {
        final doc = FirebaseFirestore.instance
            .collection('T04_Event')
            .doc("cvabc8IsVAGQjYwPv0fR")
            .collection('T01_Audition')
            .doc(auditions[i].docid);

        await doc.update({
          "T08_flag": 0,
        });
        auditions.removeAt(i);
      }
    }
    this.auditions = auditions;
    // for (var i = 0; i >= auditions.length; i ++) {
    //   if(now.isBefore(auditions[i].schedule.toDate())) {

    //   }
    // }
    print('len = ' + auditions.length.toString());
    yield auditions;
  }

  // Stream<List> fetchEvents() async* {
  //   // Firestoreからコレクション'books'(QuerySnapshot)を取得してdocsに代入。
  //   final docs_audi = await FirebaseFirestore.instance
  //       .collection('T04_Event')
  //       .doc('cvabc8IsVAGQjYwPv0fR')
  //       .collection('T01_Audition')
  //       .get();
  //   // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
  //   // map(): Listの各要素をBookに変換
  //   // toList(): Map()から返ってきたIterable→Listに変換する。
  //   final auditions = docs_audi.docs.map((doc) => Audition(doc)).toList();
  //   this.auditions = auditions;
  //   print('len = ' + auditions.length.toString());
  //   yield auditions;
  // }
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
        stream: fetchEvents(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("wait");
          } else if (snapshot.hasData) {
            return ListView.separated(
                itemCount: auditions.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 80,
                    child: ListTile(
                      title: Text(
                        auditions[index].name,
                      ),
                      subtitle: fromAtNow(auditions[index].schedule.toDate()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudiOverview(auditions, index)
                          )
                        );
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
              },
            );
          } else {
            return const Text("オーディションは開催されていません",style: TextStyle(fontSize: 30,));
          }
        },
    );
  }
}

class Audition {
  // Auditionで扱うフィールドを定義しておく。
  String name = "";
  String item = "";
  Timestamp schedule = Timestamp(2020, 10);
  String company = "";
  String url = "";
  String docid = "";

  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  Audition(DocumentSnapshot doc) {
    //　ドキュメントの持っているフィールドをこのAuditionのフィールドにそれぞれ代入
    name = doc['T05_Name'];
    item = doc['T01_Item'];
    schedule = doc['T02_Schedule'];
    company = doc['T03_Company'];
    url = doc['T06_image'];
    docid = doc['T07_DocumentId'];
  }
}
