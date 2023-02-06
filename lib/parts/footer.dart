// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../functions.dart';

// class Footer extends StatefulWidget {
//   Footer({Key? key}) : super(key: key);
//   @override
//   _Footer createState() => _Footer();

// }

// class _Footer extends State {
//   // var user_Q = FirebaseFirestore.instance
//   //     .collection('T01_Person')
//   //     .where('T01_AuthId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

//   @override
//   Widget build(BuildContext context) {
//     User? user=FirebaseAuth.instance.currentUser;
//     String? keys=FirebaseAuth.instance.currentUser!.displayName;

//     var nameid = devideUser(user!);

//     // 取得した@、#、-でボタンの数を分ける
//     switch (nameid) {
//             case 2:
//               return BottomNavigationBar(
//                   items: const [
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.home),
//                       label: "ホーム",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.account_box),
//                       label: "マイページ",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.star),
//                       label: "大会",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.format_list_numbered_rtl),
//                       label: "ランキング",
//                     ),

//                   ],
//                     type: BottomNavigationBarType.fixed,
//               );
//               break;
//           case 1:
//               return BottomNavigationBar(
//                   items: const [
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.home),
//                       label: "芸人",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.account_box),
//                       label: "マイページ",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.star),
//                       label: "イベント",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.format_list_numbered_rtl),
//                       label: "ランキング",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.chat),
//                       label: "チャット",
//                     ),
//                   ],
//                     type: BottomNavigationBarType.fixed,
//               );
//               break;
//           default:
//             return BottomNavigationBar(
//               items: const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: "管理者",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: "",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: "",
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home),
//                   label: "",
//                 ),
//               ],
//                 type: BottomNavigationBarType.fixed,
//             );
//             break;
//     }

//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import '../functions.dart';
import '../profile/owaraizukiProfile.dart';
import '../home/home.dart';
import '../event/convention_list.dart';
import "../home/Ranking.dart";
import '../event/events_list.dart';

import '../profile/geininProfile.dart';
// import '../chat/RoomRistPage.dart';
import '../chat/ChatMane.dart';

class Footer extends StatefulWidget {
  Footer({Key? key}) : super(key: key);
  @override
  _Footer createState() => _Footer();
}

class _Footer extends State {
  // var user_Q = FirebaseFirestore.instance
  //     .collection('T01_Person')
  //     .where('T01_AuthId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  User? user = FirebaseAuth.instance.currentUser;
  var _selectIndex = 0;
  String shoukai = "";
  String documentId = "";

  void aikataEdit() async {
    final userGid = await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .get();

    final gid =
        FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid);
    // T02_Geininの自分のdocumentIdを取得
    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where('T02_GeininId', isEqualTo: gid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach(
                (doc) {
                  documentId = doc.id;
                },
              ),
            });
    final ref = await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .doc(documentId)
        .get();
    shoukai = ref.data()!["T02_describe"];
  }

  // BottomNavigationBarで画面遷移先の一覧
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? keys = FirebaseAuth.instance.currentUser!.displayName;

    // BottomNavigationBarがタップされた時に、選択中のインデックスを変更する関数を用意します。
    void _onTapItem(int index) {
      setState(() {
        _selectIndex = index; //インデックスの更新
      });
    }

    var nameid = devideUser(user!);
    // 取得した@、#、-でボタンの数を分ける
    switch (nameid) {
      case 2:
        var _pages = <Widget>[
          Home(),
          owaraizukiProfile(),
          Conventions(),
          Ranking()
        ];
        return Scaffold(
            body: _pages[_selectIndex],
            bottomNavigationBar: BottomNavigationBar(
              // お笑い好きフッター色
              backgroundColor: Color.fromARGB(255, 255, 166, 077),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "ホーム",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_box),
                  label: "マイページ",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: "大会",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.format_list_numbered_rtl),
                  label: "ランキング",
                ),
              ],
              currentIndex: _selectIndex,
              onTap: _onTapItem,
              type: BottomNavigationBarType.fixed,
            ));

        break;
      case 1:
        aikataEdit();
        var _pages = <Widget>[
          Home(),
          geininProfile(shoukai),
          Events(),
          ChatMane(),
          Ranking(),
        ];
        return Scaffold(
            body: _pages[_selectIndex],
            bottomNavigationBar: BottomNavigationBar(
              // 芸人フッター色
              selectedItemColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 255, 166, 077),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    // color: Colors.white,
                  ),
                  label: "芸人",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_box),
                  label: "マイページ",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: "イベント",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: "チャット",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.format_list_numbered_rtl),
                  label: "ランキング",
                ),
              ],
              currentIndex: _selectIndex,
              onTap: _onTapItem,
              type: BottomNavigationBarType.fixed,
            ));
        break;
      default:
        return BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "管理者",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "",
            ),
          ],
          type: BottomNavigationBarType.fixed,
        );
        break;
    }
  }
}
