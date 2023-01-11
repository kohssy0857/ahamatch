import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';
import '../parts/header.dart';
import 'convention_list.dart';
import 'events_list.dart';
import '../functions.dart';

class ConOverview extends StatelessWidget {
  final List<Convention> model;
  // AuditionManagement画面にあるそれぞれのindex番号を取得している
  final int index;
  String conventionName = "****";
  String condition = "ちょめ";
  DateTime schedule = DateTime(2020, 10, 2, 12, 10);
  String prize = "ちゃめ放送";
  ConOverview(this.model, this.index) {}
  
  @override
  // _ConOverview createState() => _ConOverview();
  Widget build(BuildContext context) {
    DateTime schedule = model[index].schedule.toDate();
    return Scaffold(
      body: SingleChildScrollView(
        // ユーザー情報を表示
        child: Column(
          children: [
            Container(
              // height: 50,
              child: Text('大会名：${model[index].name}'),
            ),
            Divider(),
            Container(
              height: 100,
              child: Text(
                '大会概要\n'+
                '条件：${model[index].condition}\n'+
                '期限：'+schedule.toString()+'\n'+
                '賞品：${model[index].prize}'),
            ),
            const Divider(),
            Container(
              child:Text('出場者一覧'),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // background
                  onPrimary: Colors.black, // foreground
                ),
                onPressed: () async {
                    Navigator.of(context).pop();
                },
                child: const Text('戻る'),
              ),
          ]),
      ),
    );
  }
}
// class _ConOverview extends State<ConOverview> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('大会情報詳細'),
//       ),
//       body: SingleChildScrollView(
//         // ユーザー情報を表示
//         child: Column(
//           children: [
//             Text('大会名：${model[index].name}'),
//           ]),
//       ),
//     );
//   }
// }
