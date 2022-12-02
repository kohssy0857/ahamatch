import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/cupertino.dart';
import '../functions.dart';
import 'package:provider/provider.dart';

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
        .get();
    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をBookに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final events = event.docs.map((doc) => Convention(doc)).toList();
    this.events = events;
    print('len = ' + events.length.toString());
    notifyListeners();
  }
}

class Conventions extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  late Image img;
  int i = 0;
  final docs = FirebaseFirestore.instance
      .collection('T04_Event') // コレクションID
      .doc("cvabc8IsVAGQjYwPv0fR")
      .collection('T02_Convention').doc();

  Stream<Image> getAvatarUrlForProfile() async* {
    final ref =
        FirebaseStorage.instance.ref().child('convention/${docs.id}.jpg');
        print('ref =${docs.id}');
    // no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();


    yield Image.network(
      url,
      height: 300,
      width: 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<MainModel>(
        // createでfetchBooks()も呼び出すようにしておく。
        create: (_) => MainModel()..fetchConventions(),
        child: Scaffold(
          appBar: const Header(),
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              final events = model.events;
              return Container(
                height: 500,
                padding: EdgeInsets.all(2),
                // 各アイテムの間にスペースなどを挟みたい場合
                child: ListView.separated(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        // StreamBuilder(
                        //   stream: getAvatarUrlForProfile(),
                        //   builder: (BuildContext context,
                        //       AsyncSnapshot<dynamic> snapshot) {
                        //     if (snapshot.connectionState ==
                        //         ConnectionState.waiting) {
                        //       return const Text("wait");
                        //     } else if (snapshot.hasData) {
                        //       Image photo = snapshot.data!;
                        //       return photo;
                        //     } else {
                        //       return const Text("not photo");
                        //     }
                        //   },
                        // ),
                        Container(
                          height: 50,
                          // color: books[index]['color'],
                          child: Text(events[index].name),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Convention {
  // Bookで扱うフィールドを定義しておく。
  String name = "";
  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  Convention(DocumentSnapshot doc) {
    //　ドキュメントの持っているフィールド'title'をこのBookのフィールドtitleに代入
    name = doc['T05_Name'];
  }
}
