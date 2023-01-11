import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post/uploadPost.dart';
import 'searchNeta.dart';


class SearchResult extends StatefulWidget {
  SearchResult({Key? key}) : super(key: key);
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
    return Scaffold(
      appBar: const Header(),
      body: SafeArea(
          child: DefaultTabController(
              length: 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: Text("ログイン情報:${user!.displayName}")),
                    TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.black12,
                        tabs: [
                          Tab(text: "ネタ"),
                          // Tab(text: "新芽"),
                          // Tab(text: "告知")
                        ]),
                    Expanded(
                        child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                          searchNeta(),
                          // Center(child: Text("RIGHT"))
                        ]))
                  ]))),
    );
  }
}
