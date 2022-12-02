import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'uploadAhaPuch.dart';
import 'uploadAnnounce.dart';
import 'uploadNeta.dart';
import 'uploadSinme.dart';

void uploadNeta() {}
void uploadSinme() {}
void uploadAnnounce() {}
void uploadAhapuch() {}

class uploadPost extends StatelessWidget {
  const uploadPost({Key? key}) : super(key: key);

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
      length: 4, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('投稿'),
          bottom: const TabBar(
            isScrollable: true, // スクロールを有効化
            tabs: <Widget>[
              Tab(text: 'ネタ'),
              Tab(text: 'アハプッチ'),
              Tab(text: '新芽'),
              Tab(text: '告知'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            sendNeta(),
            sendAhaPuch(),
            sendSinme(),
            sendAnnounce(),
          ],
        ),
      ),
    );
  }
}
