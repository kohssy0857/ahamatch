import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      length: 8, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ホーム'),
          bottom: const TabBar(
            isScrollable: true, // スクロールを有効化
            tabs: <Widget>[
              Tab(text: '野球'),
              Tab(text: 'サッカー'),
              Tab(text: 'テニス'),
              Tab(text: 'バスケ'),
              Tab(text: '剣道'),
              Tab(text: '柔道'),
              Tab(text: '水泳'),
              Tab(text: '卓球'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            Center(
              child: Text('野球', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('サッカー', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('テニス', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('バスケ', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('剣道', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('柔道', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('水泳', style: TextStyle(fontSize: 32.0)),
            ),
            Center(
              child: Text('卓球', style: TextStyle(fontSize: 32.0)),
            ),
          ],
        ),
      ),
    );
  }
}

class sendPost extends StatefulWidget {
  @override
  _sendPostState createState() => _sendPostState();
}

void uploadNeta() {}
void uploadSinme() {}
void uploadAnnounce() {}
void uploadAhapuch() {}

class _sendPostState extends State<sendPost> {
  // 入力された内容を保持するコントローラ
  final inputController = TextEditingController();
  // 表示用の変数
  String inputText = "最初の表示";
  // 入力されたときの処理
  void setText(String s) {
    setState(() {
      inputText = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Column1
        Container(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              height: 100,
              child: TextField(
                enabled: true, //活性or非活性
                maxLength: 10, //入力最大文字数
                style: TextStyle(color: Colors.red), //入力文字のスタイル
                obscureText: false, //trueでマスク（****表記）にする
                maxLines: 1, //入力可能行数
                controller: inputController,
              ),
            )),
        // Column2
        GestureDetector(
          onTap: () {
            setText(inputController.text);
          },
          child: Text("入力が終わったら押してみて"),
        ),
        // Column3
        Text(inputText),
      ],
    );
  }
}
