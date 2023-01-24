import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post/uploadPost.dart';
import 'searchNeta.dart';
import 'searchAccount.dart';
import 'searchTag.dart';

// void searchNeta() {}
class SearchResult extends StatefulWidget {
  final String _editController;
  SearchResult(this._editController, {Key? key})
      : super(key: key);
  // Home(){
  // }
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  // const SearchResult({Key? key}) : super(key: key);
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoUrls = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('検索結果'),
            bottom: TabBar(
              tabs: [
                Tab(text: "ネタ"),
                Tab(text: "アカウント"),
                Tab(text: "タグ")
              ]),
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(child: Text("ログイン情報:${user!.displayName}")),
          Expanded(
              child: TabBarView(
                  // physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                searchNeta(word: widget._editController,),
                SearchResultMane(word: widget._editController,),
                searchTag(word: widget._editController,),
                // Center(child: Text("RIGHT"))
              ]
            )
          )
        ]
      )
      )
    );
  }
}
