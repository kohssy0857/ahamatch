import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Footer extends StatefulWidget {
  Footer({Key? key}) : super(key: key);
  @override
  _Footer createState() => _Footer();
      
}

class _Footer extends State {
  // var user_Q = FirebaseFirestore.instance
  //     .collection('T01_Person')
  //     .where('T01_AuthId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  
  
  @override
  Widget build(BuildContext context) {
    User? user=FirebaseAuth.instance.currentUser;
    String? keys=FirebaseAuth.instance.currentUser!.displayName;

    // @、#、-のインデックス位置取得
    var nameid = 1;
    if(user!.displayName!.indexOf('@')!=null){
      nameid = user!.displayName!.indexOf('@');
    } else if(user!.displayName!.indexOf('#')!=null){
      nameid = user!.displayName!.indexOf('#');
    }else{
      nameid = user!.displayName!.indexOf('-');
    }
    
    
    // 取得した@、#、-でボタンの数を分ける
    switch (user!.displayName![nameid]) {
            case "@":
              return BottomNavigationBar(
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
                    type: BottomNavigationBarType.fixed,
              );
              break;
          case "#":
              return BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
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
                      icon: Icon(Icons.format_list_numbered_rtl),
                      label: "ランキング",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat),
                      label: "チャット",
                    ),
                  ],
                    type: BottomNavigationBarType.fixed,
              );
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
