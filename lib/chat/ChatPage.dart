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

class ChatPage extends StatefulWidget {
  // const ChatPage(this.name, {Key? key}) : super(key: key);

  final String name;
  String PersonId = "";
  DocumentReference<Map<String, dynamic>> GeininId;
  ChatPage(this.name, this.GeininId) {
    PersonId = GeininId.path.replaceFirst("T01_Person/", "");
    // print("お名前なんだえ");
    // print(name);
  }
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final user = FirebaseAuth.instance.currentUser;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  // 二人のユーザーリスト
  Map<String, bool> joinedUsers = {};
  String elementId = "";
  Stream<QuerySnapshot>? chats;
  String sendUserName = "";

  // ^^^^^^^^^^^^^^^^^^^^
  String userName = "名無し";
  // Stream<QuerySnapshot<Map<String, dynamic>>> getData;
  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChats() async {
    await FirebaseFirestore.instance
        .collection('T06_Chat')
        .where(
          'T06_JoinedUsers.${user!.uid}',
          isEqualTo: true,
        )
        .where(
          'T06_JoinedUsers.${widget.PersonId}',
          isEqualTo: true,
        )
        .get()
        .then((QuerySnapshot querySnapshot) async => {
              if (querySnapshot.docs.isEmpty)
                {
                  // print("ルームないよ"),
                  joinedUsers.addAll({user!.uid: true, widget.PersonId: true}),
                  // T06_Chatの次のドキュメントに
                  await FirebaseFirestore.instance
                      .collection('T06_Chat')
                      .doc()
                      .set({
                    "T06_JoinedUsers": joinedUsers,
                  }),
                  await FirebaseFirestore.instance
                      .collection('T06_Chat')
                      .where(
                        'T06_JoinedUsers.${user!.uid}',
                        isEqualTo: true,
                      )
                      .where(
                        'T06_JoinedUsers.${widget.PersonId}',
                        isEqualTo: true,
                      )
                      .get()
                      .then((QuerySnapshot querySnapshot) async => {
                            querySnapshot.docs.forEach(
                              (doc) {
                                elementId = doc.id;
                              },
                            ),
                          }),
                }
              else
                {
                  // print("ルームあるよ"),
                  querySnapshot.docs.forEach((element) async {
                    // print(element.id);
                    elementId = element.id;
                  }),
                }
            });
    return await FirebaseFirestore.instance
        .collection('T06_Chat')
        .doc(elementId)
        .collection('contents')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  getChatandAdmin() {
    getChats().then((val) {
      setState(() {
        chats = val;
      });
    });
  }
  // ^^^^^^^^^^^^^^^^^^^

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name}'),
        backgroundColor: Color.fromARGB(255, 255, 166, 077),
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.pink[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
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
                  return MessageTile(
                      message: snapshot.data.docs[index]['text'],
                      sender: snapshot.data.docs[index]['uid'],
                      sentByMe: user!.uid == snapshot.data.docs[index]['uid']);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() async {
    // await FirebaseFirestore.instance
    //     .collection('T01_Person')
    //     .get()
    //     .then((QuerySnapshot snapshot) {
    //   snapshot.docs.forEach((doc) {
    //     /// usersコレクションのドキュメントIDを取得する
    //     allUserId.add(doc.id);
    //   });
    // });
    // for(int i=0;i<allUserId.length;i++){
    final gid =
        FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid);

    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where(
          'T02_GeininId',
          isEqualTo: gid,
        )
        .get()
        .then((QuerySnapshot snapshot) async => {
              snapshot.docs.forEach((doc) async {
                sendUserName = doc.get("T02_UnitName");
              })
            });
      await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(widget.PersonId)
        .collection("Notification")
        .doc().set({
      "Create": Timestamp.fromDate(DateTime.now()),
      "Text": "${sendUserName}から新着メッセージが送られました",
      "unread": true,
});
//     }
    String message = messageController.text;
    if (messageController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('T06_Chat')
          .doc(elementId)
          .collection('contents')
          .add({
        'uid': user!.uid,
        'name': "名無し",
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'text': message,
      });
      setState(() {
        messageController.clear();
      });
    }
  }
}
