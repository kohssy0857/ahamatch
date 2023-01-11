import 'dart:ffi';

import 'package:ahamatch/home/ConventionInput.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import '../profile/geininFollowProfile.dart';
import 'ChatPage.dart';
import 'ChatClass.dart';

// class RoomChat extends StatefulWidget {
//    RoomChat({Key? key}) : super(key: key);

//   @override
//   _RoomChatState createState() => _RoomChatState();
// }

// class _RoomChatState extends State<RoomChat> {
//   final user = FirebaseAuth.instance.currentUser;
//   final userId = FirebaseAuth.instance.currentUser!.uid;

//   List<ChatInfo>? ChatInfoList;

//   // void fetchChatList () async{
//   //   String elementId = "";
//   //   var data;
//   //   await FirebaseFirestore.instance
//   //           .collection('T06_Chat')
//   //           .where(
//   //             'T06_JoinedUsers.${user!.uid}',
//   //             isEqualTo: true,
//   //           ).get().then(
//   //             (QuerySnapshot querySnapshot) async => {
//   //               if(querySnapshot.docs.isEmpty){
//   //                 print("履歴ないよ"),
//   //               }else{
//   //                 print("履歴あるよ"),
//   //                 querySnapshot.docs.forEach((element)  async{
//   //                   // print(element.id);
//   //                   elementId = element.id;
//   //                   data=FirebaseFirestore.instance
//   //                   .collection('T06_Chat')
//   //                   .doc(elementId)
//   //                   .collection('contents').orderBy('createdAt', descending: true)
//   //                   .snapshots();

//   //                   data.listen((QuerySnapshot snapshot) {
//   //                 // map関数→toList関数
//   //                 // 与えられた各要素を新しく格納する値として修正し、それらを新しいリストとする
//   //                   final List<ChatInfo> ChatInfoList = snapshot.docs.map((DocumentSnapshot document) {
//   //                   // Map型は、keyと呼ばれる値とvalueと呼ばれる値を紐付けて格納するオブジェクトです。
//   //                   // キーを指定して値を配列に格納
//   //                   Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//   //                   final String title = data['name'];
//   //                   final String author = data['text'];
//   //                   return ChatInfo(title, author);
//   //                 }).toList();

//   //                 this.ChatInfoList = ChatInfoList;
//   //                 // notifyListeners();
//   //               });
//   //             }
//   //                 ),

//   //               }
//   //             }
//   //           );
//   // }

//   Stream<dynamic> getVideo() async* {
//     // final data =await FirebaseFirestore.instance
//     //         .collection('T06_Chat')
//     //         .where(
//     //           'T06_JoinedUsers.${user!.uid}',
//     //           isEqualTo: true,
//     //         ).snapshots();
//     String elementId = "";
//     var data;
//     await FirebaseFirestore.instance
//             .collection('T06_Chat')
//             .where(
//               'T06_JoinedUsers.${user!.uid}',
//               isEqualTo: true,
//             ).get().then(
//               (QuerySnapshot querySnapshot) async => {
//                 if(querySnapshot.docs.isEmpty){
//                   print("履歴ないよ"),
//                 }else{
//                   print("履歴あるよ"),
//                   querySnapshot.docs.forEach((element)  async{
//                     // print(element.id);
//                     elementId = element.id;
//                     data=FirebaseFirestore.instance
//                     .collection('T06_Chat')
//                     .doc(elementId)
//                     .collection('contents').orderBy('createdAt', descending: true)
//                     .snapshots();
//                   }),

//                 }
//               }
//             );
//     print("ttttttt");
//     print(data);
//     yield data;
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('チャット'),
//       ),
//       body: Column(
//         children: <Widget>[
//           StreamBuilder(
//             stream: getVideo()
//           //   stream: 
//           // FirebaseFirestore.instance
//           //   .collection('T06_Chat')
//           //   .where(
//           //     'T06_JoinedUsers.${user!.uid}',
//           //     isEqualTo: true,
//           //   ).snapshots()
//           ,builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                     if(snapshot.connectionState == ConnectionState.waiting){
//                       return const Text("no photo");
//                     }else if (snapshot.hasData){
//                       print("aaaaaaaaaaaaaaa");
//                       print(snapshot.data);
//                       var doc = snapshot.data!;
//                       // print(doc);
//                         return Card(
//                           margin: const EdgeInsets.all(10),
//                           child: ListTile(
//                             title: Text("aa"),
//                           )
//                         );
//                     } else {
//                       return const Text("not photo");
//                     }
//                     },),
//           // Card(
//           //   margin: const EdgeInsets.all(10),
//           //   child: ListTile(
//           //     // leading: Image.network(T02_Convention[index].T06_image),
//           //     title: Text("芸名："),
//           //     // subtitle: Text(T02Geinin[index].ID), // 商品名
//           //     // onTap: () async {
//           //     //             Navigator.push(
//           //     //               // ボタン押下でオーディション編集画面に遷移する
//           //     //                 context, MaterialPageRoute(builder: (context) => ChatPage(T02Geinin[index].T02_UnitName,T02Geinin[index].T02_GeininId)));
//           //     //             /* --- 省略 --- */
//           //     //           } ,
//           //     // subtitle: Text(T01_Audition['price'].toString()), // 価格
//           //   ),
//           // ),
//         ],
//       )
//     );
//   }
// }



class ChatListModel extends ChangeNotifier{
  final user = FirebaseAuth.instance.currentUser;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List elementIdList = [];

  void _getElementId() async{
    String elementId = "";
    var data;
    // var listt;
    await FirebaseFirestore.instance
            .collection('T06_Chat')
            .where(
              'T06_JoinedUsers.${user!.uid}',
              isEqualTo: true,
            ).get().then(
              (QuerySnapshot querySnapshot) async => {
                if(querySnapshot.docs.isEmpty){
                  print("履歴ないよ"),
                }else{
                  print("履歴あるよ"),
                  querySnapshot.docs.forEach((element)  async{
                    // print(element.id);
                    elementId = element.id;
                    elementIdList.add(elementId);
                  }),
                }
              }
            );
  }

  List<ChatInfo>? ChatInfoList;
    void fetchChatList () async{
    String elementId = "";
    var data;
    // var listt;
                  data=await FirebaseFirestore.instance
                          .collection('T06_Chat')
                          .where(
                            'T06_JoinedUsers.${user!.uid}',
                            isEqualTo: true,
                          ).snapshots();
                    data.listen((QuerySnapshot snapshot) {
                  // map関数→toList関数
                  // 与えられた各要素を新しく格納する値として修正し、それらを新しいリストとする
                    final List<ChatInfo> ChatInfoList = snapshot.docs.map((DocumentSnapshot document) {
                    // Map型は、keyと呼ばれる値とvalueと呼ばれる値を紐付けて格納するオブジェクトです。
                    // キーを指定して値を配列に格納
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    final String title = data['name'];
                    final String author = data['text'];
                    return ChatInfo(title, author);
                  }).toList();

                  this.ChatInfoList = ChatInfoList;
                  notifyListeners();
                }
                                  );
              }
}

class RoomChat extends StatelessWidget {
  const RoomChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Providerの上位Widgetの値の取得を発展させ、データが変わったことを通知する
    return ChangeNotifierProvider<ChatListModel>(
      // BookListModelのfetchBookList()を..で呼び出す👇
      create: (_) => ChatListModel()..fetchChatList(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット履歴'),
        ),
        body: Center(
          // Consumerは、インスタンスが変更されるとbuilderに渡された関数がビルドされます。
          child: Consumer<ChatListModel>(builder: (context, model, child) {
            final List<ChatInfo>? books = model.ChatInfoList;

            if (books == null) {
              // 🌀回るアイコンを表示する
              return const CircularProgressIndicator();
            }
            // 与えられた各要素に処理を掛けた後に、その要素群に対する新しいリストを作成する。
            final List<Widget> widgets = books
                .map(
                  (book) => ListTile(
                title: Text(book.name),
                subtitle: Text(book.text),
              ),
            )
                .toList();
            return ListView(
              children: widgets,
            );
          }),
        ),
        // floatingActionButton: const FloatingActionButton(
        //   onPressed: null,
        //   tooltip: 'Increment',
        //   child: Icon(Icons.add),
        // ),
      ),
    );
  }
}

