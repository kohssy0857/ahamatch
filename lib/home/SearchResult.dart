import 'dart:ffi';

import 'package:ahamatch/home/ConventionInput.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import '../profile/geininFollowProfile.dart';

class SearchResult {

  String ID = "";
  late DocumentReference<Map<String, dynamic>> T02_GeininId ;
  Timestamp T02_Create=Timestamp(2020, 10);
  String T02_UnitName = "";

  // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
  SearchResult(DocumentSnapshot doc) {
    //　ドキュメントの持っているフィールド'T01_Conditions'取得
    // print("doc['T02_GeininId']");
    // print(doc['T02_GeininId']);
    T02_GeininId = doc['T02_GeininId'];
    // //　ドキュメントの持っているフィールド'T04_Create'取得
    T02_Create = doc['T02_Create'];
    // 　ドキュメントの持っているフィールド'T05_Name'取得
    T02_UnitName = doc['T02_UnitName'];
    // ドキュメントのid取得
    ID = doc.id;
  }
}

class MainModel extends ChangeNotifier {
  // ListView.builderで使うためのT01_AuditionのList booksを用意しておく。　
  List<SearchResult> T02_Geinin = [];

  Future<void> fetchConvention() async {
    // Firestoreからコレクション'T04_Event'、ドキュメントID''、コレクション'T01_Audition'(QuerySnapshot)を取得してdocsに代入。
    final docs = await FirebaseFirestore.instance.collection("T02_Geinin").get();

    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をT01_Auditionに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final T02Geinin  = docs.docs
        .map((doc) => SearchResult(doc)) 
        .toList();
    this.T02_Geinin = T02Geinin; 
    notifyListeners(); 
  }
}

class SearchResultMane extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<MainModel>(
        // createでfetchBooks()も呼び出すようにしておく。
        create: (_) => MainModel()..fetchConvention(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('検索結果一覧'),
          ),
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              // FirestoreのドキュメントのList booksを取り出す。
              final T02Geinin = model.T02_Geinin; 
              return ListView.builder(
                // Listの長さを先ほど取り出したbooksの長さにする。
                itemCount: T02Geinin.length,
                // indexにはListのindexが入る。
                itemBuilder: (context, index) {
                  if(user!.uid==T02Geinin[index].T02_GeininId.path.replaceFirst("T01_Person/", "")){
                    return Card();
                  } else {return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      // leading: Image.network(T02_Convention[index].T06_image),
                      title: Text(T02Geinin[index].T02_UnitName),
                      subtitle: Text(T02Geinin[index].ID), // 商品名
                      onTap: () async {
                                  Navigator.push(
                                    // ボタン押下でオーディション編集画面に遷移する
                                      context, MaterialPageRoute(builder: (context) => geininFollowProfile(model,index,T02Geinin[index].T02_GeininId)));
                                  /* --- 省略 --- */
                                } ,
                      // subtitle: Text(T01_Audition['price'].toString()), // 価格
                    ),
                  );
                  }
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Navigator.push(
            // ボタン押下でオーディション情報入力画面に遷移する
              context, MaterialPageRoute(builder: (context) => ConventionInput()));
          /* --- 省略 --- */
        },
      ),
    );
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}

// class SearchResult {

//   String ID = "";
//   String T01_Conditions = "";
//   Timestamp T02_Schedule = Timestamp(2020, 10) ;
//   String T03_Prize = "";
//   Timestamp T04_Create=Timestamp(2020, 10);
//   String T05_Name = "";
//   String? T06_image = "";

//   // ドキュメントを扱うDocumentSnapshotを引数にしたコンストラクタを作る
//   SearchResult(DocumentSnapshot doc) {
//     //　ドキュメントの持っているフィールド'T01_Conditions'取得
//     T01_Conditions = doc['T01_Conditions'];
//     // 　ドキュメントの持っているフィールド'T02_Schedule'取得
//     T02_Schedule = doc['T02_Schedule'];
//     // //　ドキュメントの持っているフィールド'T03_Prize'取得
//     T03_Prize = doc['T03_Prize'];
//     // //　ドキュメントの持っているフィールド'T04_Create'取得
//     T04_Create = doc['T04_Create'];
//     // 　ドキュメントの持っているフィールド'T05_Name'取得
//     T05_Name = doc['T05_Name'];
//     // ドキュメントのid取得
//     ID = doc.id;
//     // ドキュメントの持っているフィールド'T06_image'取得
//     T06_image = doc['T06_image'];
//   }
// }

// class MainModel extends ChangeNotifier {
//   // ListView.builderで使うためのT01_AuditionのList booksを用意しておく。　
//   List<SearchResult> T02_Convention = [];

//   Future<void> fetchConvention() async {
//     // Firestoreからコレクション'T04_Event'、ドキュメントID''、コレクション'T01_Audition'(QuerySnapshot)を取得してdocsに代入。
//     final docs = await FirebaseFirestore.instance.collection("T04_Event").doc("cvabc8IsVAGQjYwPv0fR").collection("T02_Convention").get();


//     // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
//     // map(): Listの各要素をT01_Auditionに変換
//     // toList(): Map()から返ってきたIterable→Listに変換する。
//     final T02Convention  = docs.docs
//         .map((doc) => SearchResult(doc)) 
//         .toList();
//     this.T02_Convention = T02Convention; 
//     notifyListeners(); 
//   }
// }

// class SearchResultMane extends StatelessWidget {

//   // FirebaseFirestoreに対して削除を促している関数
//   Future deleteProduct(String productId) {
//     return FirebaseFirestore.instance.collection("T04_Event").doc("cvabc8IsVAGQjYwPv0fR").collection("T02_Convention").doc(productId).delete();
//   }

//   // 削除ボタン押下時の関数
//   Future showConfirmDialog(BuildContext context,int index,MainModel model){
//         return  showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) {
//           return AlertDialog(
//             title: Text("削除の確認"),
//             content: Text("削除しますか？"),
//             actions: [
//               TextButton(
//                 child: Text("いいえ"),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               TextButton(
//                 child: Text("はい"),
//                 onPressed: () async {
//                   // オーディション情報の削除関数を呼ぶ
//                   deleteProduct(model.T02_Convention[index].ID);
//                   // はいボタンを押下時、ダイアログを消す
//                   Navigator.pop(context);
//                   // 削除後、下にスナックバーを表示
//                   final snackBar = SnackBar(
//                     backgroundColor: Colors.red,
//                     content: Text("削除しました"),);
//                     model.fetchConvention();
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     }
//               ),
//             ],
//           );
//         },
//       );
//     }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ChangeNotifierProvider<MainModel>(
//         // createでfetchBooks()も呼び出すようにしておく。
//         create: (_) => MainModel()..fetchConvention(),
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text('検索結果一覧'),
//           ),
//           body: Consumer<MainModel>(
//             builder: (context, model, child) {
//               // FirestoreのドキュメントのList booksを取り出す。
//               final T02Convention = model.T02_Convention; 
//               return ListView.builder(
//                 // Listの長さを先ほど取り出したbooksの長さにする。
//                 itemCount: T02Convention.length,
//                 // indexにはListのindexが入る。
//                 itemBuilder: (context, index) {
//                   // print("URL---------------------");
//                   // print(T01Audition[index].T06_image);
//                   return Card(
//                     margin: const EdgeInsets.all(10),
//                     child: ListTile(
//                       // leading: Image.network(T02_Convention[index].T06_image),
//                       title: Text(T02Convention[index].T05_Name), // 商品名
//                       // subtitle: Text(T01_Audition['price'].toString()), // 価格
//                       trailing: SizedBox(
//                         width: 100,
//                         child: Row(
//                           children: [
//                             // 編集ボタン
//                             // IconButton(
//                             //   color: Colors.deepOrange[400],
//                             //     icon: const Icon(Icons.edit),
//                             //     onPressed: () async {
//                             //       Navigator.push(
//                             //         // ボタン押下でオーディション編集画面に遷移する
//                             //           context, MaterialPageRoute(builder: (context) => ConventionEdit(model,index)));
//                             //       /* --- 省略 --- */
//                             //     }),
//                             // 削除ボタン
//                             // IconButton(
//                             //     color: Colors.red[700],
//                             //     icon: const Icon(Icons.delete),
//                             //     onPressed: () async =>
//                             //     await showConfirmDialog(context,index,model)
//                             //         )
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () async {
//           Navigator.push(
//             // ボタン押下でオーディション情報入力画面に遷移する
//               context, MaterialPageRoute(builder: (context) => ConventionInput()));
//           /* --- 省略 --- */
//         },
//       ),
//     );
//   }
// }

// Stream<QuerySnapshot> getStreamSnapshots(String collection) {
//   return FirebaseFirestore.instance
//       .collection(collection)
//       .where("title", isEqualTo: "test")
//       .orderBy('createdAt', descending: true)
//       .snapshots();
// }


