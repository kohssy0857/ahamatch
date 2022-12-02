import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class sendAnnounce extends StatefulWidget {
  @override
  _sendAnnounceState createState() => _sendAnnounceState();
}

class _sendAnnounceState extends State<sendAnnounce> {
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

  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
      ),
    );
  }
}
