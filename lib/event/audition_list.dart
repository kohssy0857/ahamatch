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

  Future<void> fetchEvents() async {
    // Firestoreからコレクション'books'(QuerySnapshot)を取得してdocsに代入。
    final docs_audi = await FirebaseFirestore.instance
        .collection('T04_Event')
        .doc('cvabc8IsVAGQjYwPv0fR')
        .collection('T01_Audition')
        .get();
    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をBookに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final auditions = docs_audi.docs.map((doc) => Audition(doc)).toList();
    this.auditions = auditions;
    // for (var i = 0; i >= auditions.length; i ++) {
    //   if(now.isBefore(auditions[i].schedule.toDate())) {
        
    //   }
    // }
    print('len = ' + auditions.length.toString());
    notifyListeners();
  }
}

class Auditions extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  late Image img;
  int i = 0;
  final docs = FirebaseFirestore.instance
      .collection('T04_Event') // コレクションID
      .doc("cvabc8IsVAGQjYwPv0fR")
      .collection('T02_Convention')
      .doc();



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<MainModel>(
        // createでfetchEvents()も呼び出すようにしておく。
        create: (_) => MainModel()..fetchEvents(),
        child: Scaffold(
          // appBar: const Header(),
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              final auditions = model.auditions;
              return Container(
                // height: 500,
                padding: EdgeInsets.all(2),
                // 各アイテムの間にスペースなどを挟みたい場合
                child:
                    // Expanded(
                    //   child:
                    //  const Text('オーディション一覧'),
                    ListView.separated(
                  // shrinkWrap: true,
                  // primary: false,
                  itemCount: auditions.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AudiOverview(auditions, index)));
                          },
                          child: Container(
                            height: 50,
                            // color: books[index]['color'],
                            child: Text(
                              auditions[index].name,
                              // style: TextStyle(fontSize: ),
                            ),
                          ),
                          // ListTile(
                          //   // color: books[index]['color'],
                          //   title: Text(
                          //     auditions[index].name,
                          //     // style: TextStyle(fontSize: ),
                          //   ),
                          //   onTap: () {
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => AudiOverview(
                          //                 auditions, index)));
                          //   },
                          // ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
                // ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Audition {
  // Conventionで扱うフィールドを定義しておく。
  String name = "";
  String item = "";
  Timestamp schedule = Timestamp(2020, 10);
  String company = "";
  String url = "";
  String id = "";

  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  Audition(DocumentSnapshot doc) {
    //　ドキュメントの持っているフィールド'T05_Name'をこのConventionのフィールドnameに代入
    name = doc['T05_Name'];
    item = doc['T01_Item'];
    schedule = doc['T02_Schedule'];
    company = doc['T03_Company'];
    url = doc['T06_image'];
    id = doc['T07_DocumentId'];
  }
}
