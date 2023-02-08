import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RoomRistPage.dart';
import 'ChatHistory.dart';
import 'ChatFollower.dart';
// import 'RoomPage.dart';
// import 'uploadAhaPuch.dart';
// import 'uploadAnnounce.dart';
// import 'uploadNeta.dart';
// import 'uploadSinme.dart';

void RoomRistPage() {}
// void RoomPage () {}
// void uploadAnnounce() {}
// void uploadAhapuch() {}

class ChatMane extends StatelessWidget {
  const ChatMane({Key? key}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'otameshi',
  //     home: Scaffold(
  //       appBar: const Header(),
  //       body: sendPost(),
  //       bottomNavigationBar: Footer(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0, // 最初に表示するタブ
      length: 3, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット'),
          backgroundColor: Color.fromARGB(255, 255, 166, 077),
          bottom: const TabBar(
            isScrollable: true, // スクロールを有効化
            tabs: <Widget>[
              Tab(text: '相手'),
              Tab(text: '履歴'),
              Tab(text: 'フォローしていないユーザー'),
              // Tab(text: '新芽'),
              // Tab(text: '告知'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            // type1
            Chat(),
            // // type2
            ChatHistory(),
            // // type3
            ChatFollowerHistory(),
            // sendSinme(),
            // // type4
            // sendAnnounce(),
          ],
        ),
      ),
    );
  }
}
