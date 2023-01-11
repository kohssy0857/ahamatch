import 'dart:ffi';

import 'package:ahamatch/home/ConventionInput.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import '../main.dart';
import 'dart:io' as io ;
import '../profile/geininFollowProfile.dart';
import '../functions.dart';
import '../login/GeininInput.dart';

class loginFollow {

  String ID = "";
  late DocumentReference<Map<String, dynamic>> T02_GeininId ;
  Timestamp T02_Create=Timestamp(2020, 10);
  String T02_UnitName = "";

  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  loginFollow(DocumentSnapshot doc) {
    //　ドキュメントの持っているフィールド'T01_Conditions'取得
    // print("doc['T02_GeininId']");
    // print(doc['T02_GeininId']);
    T02_GeininId = doc['T02_GeininId'];
    // //　ドキュメントの持っているフィールド'T04_Create'取得
    T02_Create = doc['T02_Create'];
    // 　ドキュメントの持っているフィールド'T05_Name'取得
    T02_UnitName = doc['T02_UnitName'];
    // ドキュメントのid取得
    ID = doc.id;
  }
}

class MainModelGeinin extends ChangeNotifier {
  // ListView.builderで使うためのT01_AuditionのList booksを用意しておく。　
  List<loginFollow> T02_Geinin = [];
  

  Future<void> fetchConvention() async {
    // Firestoreからコレクション'T04_Event'、ドキュメントID''、コレクション'T01_Audition'(QuerySnapshot)を取得してdocsに代入。
    final docs = await FirebaseFirestore.instance.collection("T02_Geinin").get();
    

    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をT01_Auditionに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final T02Geinin  = docs.docs
        .map((doc) => loginFollow(doc)) 
        .toList();
    this.T02_Geinin = T02Geinin; 
    notifyListeners(); 
  }

  
}

class loginFollowMane extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<MainModelGeinin>(
        // createでfetchBooks()も呼び出すようにしておく。
        create: (_) => MainModelGeinin()..fetchConvention(),
        child: Scaffold(
          appBar: const Header(),
          body: Consumer<MainModelGeinin>(
            builder: (context, model, child) {
              // FirestoreのドキュメントのList booksを取り出す。
              final T02Geinin = model.T02_Geinin; 
              return ListView.builder(
                // Listの長さを先ほど取り出したbooksの長さにする。
                itemCount: T02Geinin.length,
                // indexにはListのindexが入る。
                itemBuilder: (context, index) {
                  // print("URL---------------------");
                  // print(T01Audition[index].T06_image);
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      // leading: Image.network(T02_Convention[index].T06_image),
                      title: Text(T02Geinin[index].T02_UnitName),
                      subtitle: Text(T02Geinin[index].ID), // 商品名
                      onTap: () async {
                                  Navigator.push(
                                    // ボタン押下でオーディション編集画面に遷移する
                                      context, MaterialPageRoute(builder: (context) => geininFollowProfile(model,index,T02Geinin[index].T02_GeininId)));
                                } ,
                      // subtitle: Text(T01_Audition['price'].toString()), // 価格
                    ),
                  );
                },
              );
            },
            // child: Center(
            //   child: ElevatedButton(
            //   onPressed: () { /* ボタンがタップされた時の処理 */
            //   Navigator.push(context,
            //             MaterialPageRoute(builder: (context) => App()));
            //   },
            //   child: Text('登録'),
            // ),
            // ),
          ),
        ),
      ),
      // switchFunction(devideUser(user));
      floatingActionButton: ElevatedButton(
              onPressed: () async {
                try {
                  if (devideUser(user) == 1) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GeininInput()));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => App()));
                  }
                } catch (e) {}
              },
              child: const Text('次へ'),
            ),
    );
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}




