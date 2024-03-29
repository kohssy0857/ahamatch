import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../parts/footer.dart';
import 'ConventionManagement.dart';
import '../parts/header.dart';
import 'AuditionManagement.dart';
import 'ConventionResult.dart';

class SysHome extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  // var user_Q = FirebaseFirestore.instance
  //     .collection('T01_Person')
  //     .where('T01_AuthId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  // var jij = user_conf.then((value) => null);
  //     final user_gi=
  // Stream<Hoge> hogeStream({required DocumentReference<Hoge> ref}) =>
  //     ref.snapshots().map(
  //           (snapshot) => snapshot.data()!,
  //         );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Center(
        // ユーザー情報を表示
        child: ListView(

          children:  <Widget>[

            ListTile(title: Text('オーディション管理')),
            Divider(),
            ListTile(
              leading: FlutterLogo(),
              title: Text('管理'),
              onTap: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AuditonMane()));
                /* --- 省略 --- */
              },
            ),
            ListTile(title: Text('大会')),
            Divider(),
            ListTile(
              leading: FlutterLogo(),
              title: Text('管理'),
              onTap: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ConventionMane()));
                /* --- 省略 --- */
              },
            ),
            ListTile(title: Text('ランキング')),
            Divider(),
            ListTile(
              leading: FlutterLogo(),
              title: Text('管理'),
            ),
            ElevatedButton(
                onPressed: () async {
                  // ログアウト処理
                  // 内部で保持しているログイン情報等が初期化される
                  // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
                  await FirebaseAuth.instance.signOut();
                  // ログイン画面に遷移＋チャット画面を破棄
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return const UserLogin();
                    }),
                  );
                },
                child: const Text('ログアウト')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AuditonMane()));
          /* --- 省略 --- */
        },
      ),
      bottomNavigationBar: Footer(),
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
