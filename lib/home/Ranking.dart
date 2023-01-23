import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';
import "RankingTab/AhaPointTab.dart";
import "RankingTab/CommentTab.dart";
import "RankingTab/HitTab.dart";

import '../parts/header.dart';

import '../functions.dart';
import '../parts/MoviePlayerWidget .dart';
import 'package:firebase_storage/firebase_storage.dart';

class Ranking extends StatefulWidget {
  Ranking({Key? key}) : super(key: key);
  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  User? user = FirebaseAuth.instance.currentUser;

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
                      Center(child: Text("ランキング！")),
                      TabBar(
                        tabs: [
                          Tab(text: "視聴回数"),
                          Tab(text: "アハポ数"),
                          Tab(text: "コメント数")
                        ],
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.black12,
                      ),
                      Expanded(
                          child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: <Widget>[
                            HitTab(),
                            AhaPointTab(),
                            CommentTab(),
                          ]))
                    ]))));
  }
}
