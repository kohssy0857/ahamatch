import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// flutter_chat_uiを使うためのパッケージをインポート
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:provider/provider.dart';
// ランダムなIDを採番してくれるパッケージ
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChatPage extends StatefulWidget {
  // const ChatPage(this.name, {Key? key}) : super(key: key);

  final String name;
  String PersonId ="";
  DocumentReference<Map<String, dynamic>> GeininId;
  ChatPage(this.name,this.GeininId){
    PersonId = GeininId.path.replaceFirst("T01_Person/", "");
    // print("相手のユーザーID");
    // print(PersonId);
  }
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final user = FirebaseAuth.instance.currentUser;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List<types.Message> _messages = [];
  String randomId = Uuid().v4();
   late types.User _user =  types.User(id: userId, firstName: '名前');
  // 二人のユーザーリスト
  Map<String,bool> joinedUsers = {};


  void initState() {
    _getMessages();
    super.initState();
  }

  // firestoreからメッセージの内容をとってきて_messageにセット
  void _getMessages() async {
    
    String elementId = "";
        await FirebaseFirestore.instance
            .collection('T06_Chat')
            .where(
              'T06_JoinedUsers.${user!.uid}',
              isEqualTo: true,
            ).where(
              'T06_JoinedUsers.${widget.PersonId}',
              isEqualTo: true,
            ).get().then(
              (QuerySnapshot querySnapshot) async => {
                if(querySnapshot.docs.isEmpty){
                  print("ルームないよ"),
                }else{
                  print("ルームあるよ"),
                  // print("自分のユーザーID"),
                  // print(user!.uid),
                  // print("userIdに何が入っとるんだい"),
                  // print(userId),
                  // print("相手のユーザーID"),
                  // print(user!.uid),
                  querySnapshot.docs.forEach((element)  async{
                    print(element.id);
                    elementId = element.id;
                    final getData = await FirebaseFirestore.instance
                    .collection('T06_Chat')
                    .doc(elementId)
                    .collection('contents').orderBy('createdAt', descending: true)
                    .get();
                final message = getData.docs
                    .map((d) => types.TextMessage(
                        author:
                            types.User(id: d.data()['uid'], firstName: d.data()['name']),
                        createdAt: d.data()['createdAt'],
                        id: d.data()['id'],
                        text: d.data()['text']))
                    .toList();
                setState(() {
                  _messages = [...message];
                });
                  }),
                }
              }
            );

    
  }

  // メッセージ内容をfirestoreにセット
  void _addMessage(types.TextMessage message) async {
    setState(() {
      _messages.insert(0, message);
    });

    
    String elementId = "";
        await FirebaseFirestore.instance
            .collection('T06_Chat')
            .where(
              'T06_JoinedUsers.${user!.uid}',
              isEqualTo: true,
            ).where(
              'T06_JoinedUsers.${widget.PersonId}',
              isEqualTo: true,
            ).get().then(
              (QuerySnapshot querySnapshot) async => {
                if(querySnapshot.docs.isEmpty){
                  print("ルームないよ"),
                  joinedUsers.addAll({user!.uid:true,widget.PersonId:true}),
                  // T06_Chatの次のドキュメントに
                  await FirebaseFirestore.instance
                      .collection('T06_Chat')
                      .doc()
                      .set({
                        "T06_JoinedUsers" : joinedUsers,
                  }),
                  await FirebaseFirestore.instance
            .collection('T06_Chat')
            .where(
              'T06_JoinedUsers.${user!.uid}',
              isEqualTo: true,
            ).where(
              'T06_JoinedUsers.${widget.PersonId}',
              isEqualTo: true,
            ).get().then(
              (QuerySnapshot querySnapshot) async => {
                querySnapshot.docs.forEach((element) {
                    print(element.id);
                    elementId = element.id;
                  }),
                  await FirebaseFirestore.instance
                    .collection('T06_Chat')
                    .doc(elementId)
                    .collection('contents')
                    .add({
                  'uid': user!.uid,
                  // 'uid': message.author.id,
                  'name': message.author.firstName,
                  'createdAt': message.createdAt,
                  'id': message.id,
                  // 'id': user!.uid,
                  'text': message.text,
                }),
                })


                }else{
                  print("ルームあるよ"),
                  print("自分のユーザーID"),
                  print(user!.uid),
                  // print("相手のユーザーID"),
                  // print(user!.uid),
                  querySnapshot.docs.forEach((element) {
                    print(element.id);
                    elementId = element.id;
                  }),
                  await FirebaseFirestore.instance
                    .collection('T06_Chat')
                    .doc(elementId)
                    .collection('contents')
                    .add({
                  // 'uid': user!.uid,
                   'uid': message.author.id,
                  'name': message.author.firstName,
                  'createdAt': message.createdAt,
                  'id': message.id,
                  // 'id': user!.uid,
                  'text': message.text,
                }),
                }
              }
            );

    
  }

  // リンク添付時にリンクプレビューを表示する
  // void _handlePreviewDataFetched(
  //   types.TextMessage message,
  //   types.PreviewData previewData,
  // ) {
  //   final index = _messages.indexWhere((element) => element.id == message.id);
  //   final updatedMessage = _messages[index].copyWith(previewData: previewData);

  //   WidgetsBinding.instance?.addPostFrameCallback((_) {
  //     setState(() {
  //       _messages[index] = updatedMessage;
  //     });
  //   });
  // }

  // メッセージ送信時の処理
  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
            author: _user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: randomId,
            text: message.text,
          );

    _addMessage(textMessage);
  }

  // void _roomcreate() async{
  //   joinedUsers.addAll({"5m5DpmQYLbbD853fFkLiZCmihkM2":true,"R7tpQyuQg0P1OPCA502okqFJ5z03":true});
  //       await FirebaseFirestore.instance
  //           .collection('T06_Chat')
  //           .where(
  //             'T06_JoinedUsers.5m5DpmQYLbbD853fFkLiZCmihkM2',
  //             isEqualTo: true,
  //           ).where(
  //             'T06_JoinedUsers.R7tpQyuQg0P1OPCA502okqFJ5z03',
  //             isEqualTo: true,
  //           ).get().then(
  //             (QuerySnapshot querySnapshot) async => {
  //               if(querySnapshot.docs.isEmpty){
  //                 print("ルームないよ"),
  //                 // T06_Chatの次のドキュメントに
  //                 await FirebaseFirestore.instance
  //                     .collection('T06_Chat')
  //                     .doc()
  //                     .set({
  //                       "T06_JoinedUsers" : joinedUsers,
  //                 }),
  //               }else{
  //                 print("ルームあるよ"),
  //                 querySnapshot.docs.forEach((element) {
  //                   print(element.id);
  //                 })
  //               }
  //             }
  //           );
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('チャット'),
        // actions: [
        //   IconButton(
        //     iconSize: 50,
        //     icon: Icon(Icons.add),
        //     onPressed: () => {
        //       _roomcreate()
        //     },
        //   ),
        // ],
      ),
      body: Chat(
        theme: const DefaultChatTheme(
          // メッセージ入力欄の色
          inputBackgroundColor: Colors.blue,
          // 送信ボタン
          sendButtonIcon: Icon(Icons.send),
          sendingIcon: Icon(Icons.update_outlined),
        ),
        // ユーザーの名前を表示するかどうか
        showUserNames: true,
        // メッセージの配列
        messages: _messages,
        // onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}