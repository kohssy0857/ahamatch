import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// flutter_chat_uiを使うためのパッケージをインポート
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:provider/provider.dart';
// ランダムなIDを採番してくれるパッケージ
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat/message_title.dart';
import 'ChatPage.dart';

class ChatFollowerHistory extends StatefulWidget {
  // const ChatPage(this.name, {Key? key}) : super(key: key);

  // final String name;
  // String PersonId ="";
  // DocumentReference<Map<String, dynamic>> GeininId;
  ChatPage() {
    // PersonId = GeininId.path.replaceFirst("T01_Person/", "");
  }
  @override
  _ChatFollowerHistoryState createState() => _ChatFollowerHistoryState();
}

class _ChatFollowerHistoryState extends State<ChatFollowerHistory> {
  final user = FirebaseAuth.instance.currentUser;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  // 二人のユーザーリスト
  Map<String, bool> joinedUsers = {};
  List elementId = [];
  List documentId = [];
  List newText = [];
  List gidList = [];
  Stream<QuerySnapshot>? chats;
  List unitNameList = [];
  List personIdList = [];
  List createList = [];
  int create = 0;
  Map<int, String> map1 = {};
  Map<int, String> map2 = {};
  Map<int, DocumentReference<Map<String, dynamic>>> map3 = {};
  List documentList = [];
  List followIdList = [];
  // late DocumentReference<Map<String, dynamic>> gid;

  // ^^^^^^^^^^^^^^^^^^^^
  String userName = "名無し";
  // Stream<QuerySnapshot<Map<String, dynamic>>> getData;
  TextEditingController messageController = TextEditingController();
  // @override
  // void initState() {
  //   // getChatandAdmin();
  //   setState(() {
  //     print("再描画");
  //     });
  //   super.initState();
  // }

  Stream<List> getVideo() async* {
    // ---------------------------------------------------------------
    await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(user!.uid)
        .collection("Follow")
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          documentList.add(doc.get('T05_GeininId'));
        });
      }
    });
    for (int i = 0; i < documentList.length; i++) {
      await FirebaseFirestore.instance
          .collection('T02_Geinin')
          .doc(documentList[i].path.replaceFirst("T02_Geinin/", ""))
          .get()
          .then((DocumentSnapshot snapshot) {
        if (personIdList.contains(snapshot.get('T02_GeininId')) == false) {
          // print("相手のPersonId");
          // print(snapshot
          //     .get('T02_GeininId')
          //     .path
          //     .replaceFirst("T01_Person/", ""));
          followIdList.add(snapshot
              .get('T02_GeininId')
              .path
              .replaceFirst("T01_Person/", ""));
        }
      });
    }
    await FirebaseFirestore.instance
        .collection('T06_Chat')
        .where(
          'T06_JoinedUsers.${user!.uid}',
          isEqualTo: true,
        )
        .get()
        .then((QuerySnapshot snapshot) async => {
              snapshot.docs.forEach((doc) async {
                documentId.add(doc.id);
                if (doc.get('T06_JoinedUsers').keys.elementAt(0) == user!.uid) {
                  elementId.add(doc.get('T06_JoinedUsers').keys.elementAt(1));
                } else {
                  elementId.add(doc.get('T06_JoinedUsers').keys.elementAt(0));
                }
              })
            });
    for (int i = 0; i < documentId.length; i++) {
      if (followIdList.contains(elementId[i]) == false ) {
        final gid = FirebaseFirestore.instance
            .collection("T01_Person")
            .doc(elementId[i]);
        personIdList.add(gid);
        await FirebaseFirestore.instance
            .collection('T06_Chat')
            .doc(documentId[i])
            .collection('contents')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get()
            .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isEmpty) {
            // newText.add("");
            create = DateTime.now().millisecondsSinceEpoch;
            createList.add(create);
            map1[create] = "メッセージを送信していません";
          } else {
            snapshot.docs.forEach((doc) {
              // newText.add(doc.get('text'));
              map1[doc.get('createdAt')] = doc.get('text');
              create = doc.get('createdAt');
              createList.add(doc.get('createdAt'));
            });
          }
        });
        await FirebaseFirestore.instance
            .collection('T02_Geinin')
            .where('T02_GeininId', isEqualTo: gid)
            .get()
            .then((QuerySnapshot querySnapshot) => {
                  querySnapshot.docs.forEach(
                    (doc) {
                      unitNameList.add(doc.get("T02_UnitName"));
                      map2[create] = doc.get("T02_UnitName");
                      gidList.add(doc.id);
                      map3[create] = gid;
                    },
                  ),
                });
      }
      createList.sort((a, b) => b.compareTo(a));
      yield elementId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getVideo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ロード中");
        } else if (snapshot.hasData) {
          List photo = snapshot.data!;
          return Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  // padding: EdgeInsets.all(250),
                  itemCount: unitNameList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        // leading: Image.network(T02_Convention[index].T06_image),
                        title: Text("${map2[createList[index]]}"),
                        subtitle:
                            Text("最新履歴：" + "${map1[createList[index]]}"), // 商品名
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      "${map2[createList[index]]}",
                                      map3[createList[index]]!)));
                          /* --- 省略 --- */
                        },
                        // subtitle: Text(T01_Audition['price'].toString()), // 価格
                      ),
                    );
                  }),
            ],
          );
        } else {
          return Column(
            children: [
              Text("ログイン情報:${user!.displayName}"),
              Text("芸人をフォローしてください"),
            ],
          );
          // return const Text("not photo");
        }
      },
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Text("${snapshot.data.docs[index]['text']}"),
                  );
                  ;
                },
              )
            : Container(
                child: Text("ないよ"),
              );
      },
    );
  }
}
