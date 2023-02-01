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
import 'footer.dart';
import 'header.dart';
import '../profile/geininFollowProfile.dart';

class _searchTag {

  String ID = "";
  late DocumentReference<Map<String, dynamic>> T02_GeininId ;
  Timestamp T02_Create=Timestamp(2020, 10);
  String T02_UnitName = "";

  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  _searchTag(DocumentSnapshot doc) {
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

class MainModel extends ChangeNotifier {
  // ListView.builderで使うためのT01_AuditionのList booksを用意しておく。　
  List<_searchTag> T02_Geinin = [];
  

  Future<void> fetchConvention(String word) async {
    // Firestoreからコレクション'T04_Event'、ドキュメントID''、コレクション'T01_Audition'(QuerySnapshot)を取得してdocsに代入。

    List<String> Tags = [];
    List<String> videoUrls = [];
    List<String> searchedNames = [];
    // ドキュメント情報を入れる箱を用意
    List documentList = [];
    List toukouList = [];

    // Stream<List> getVideo() async* {

      // if (documentList.isNotEmpty == true) {
        // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
        // await FirebaseFirestore.instance
        //     .collection('T02_Geinin')
        //     .get()
        //     .then((QuerySnapshot snapshot) {
        //   snapshot.docs.forEach((doc) {
        //     // if (doc["T05_Type"] == 1) {
        //       Tags.add(doc["T02_Tags"]);
        //   });
        // });
        // if (word.trim().isEmpty) {
        //   searchedNames = [];
        // } else {
        //   searchedNames = Tags.where((element) => element.contains(word)).toList();
        // }
      // }
      // ignore: unrelated_type_equality_checks
      // if (searchedNames.isNotEmpty) {
        final docs = await FirebaseFirestore.instance.collection("T02_Geinin")
        // .where("T02_PartnerRecruit", isEqualTo: true)
        .where("T02_Tags", arrayContains: word)
        .get();
        final T02Geinin  = docs.docs
            .map((doc) => _searchTag(doc)) 
            .toList();
        this.T02_Geinin = T02Geinin; 
      // }
    notifyListeners(); 
  }
}

class searchTag extends StatelessWidget {
    final String word;
  searchTag({Key? key, required this.word,}) : super(key: key);
  final user = FirebaseAuth.instance.currentUser;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<MainModel>(
        // createでfetchBooks()も呼び出すようにしておく。
        create: (_) => MainModel()..fetchConvention(word),
        child: Scaffold(
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              // FirestoreのドキュメントのList booksを取り出す。
              final T02Geinin = model.T02_Geinin; 
              if (T02Geinin.isNotEmpty == true) {
                return ListView.builder(
                  // Listの長さを先ほど取り出したbooksの長さにする。
                  itemCount: T02Geinin.length,
                  // indexにはListのindexが入る。
                  itemBuilder: (context, index) {
                    if(user!.uid==T02Geinin[index].T02_GeininId.path.replaceFirst("T01_Person/", "")){
                      return Card();
                    } else {return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        // leading: Image.network(T02_Convention[index].T06_image),
                        title: Text(T02Geinin[index].T02_UnitName),
                        subtitle: Text(T02Geinin[index].ID), // 商品名
                        onTap: () async {
                                    Navigator.push(
                                      // ボタン押下でオーディション編集画面に遷移する
                                        context, MaterialPageRoute(builder: (context) => geininFollowProfile(model,index,T02Geinin[index].T02_GeininId)));
                                    /* --- 省略 --- */
                                  } ,
                        // subtitle: Text(T01_Audition['price'].toString()), // 価格
                      ),
                    );
                    }
                  },
                );
              } else {
                return Column(
                        children: [
                          Text("該当するデータはありません"),
                        ],
                      );
              }
            },
          ),
        ),
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
