import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../parts/footer.dart';

import '../parts/header.dart';

import '../functions.dart';

class Home extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    switch (devideUser(user)) {
      case 1:
        return Scaffold(
          appBar: const Header(),
          body: Center(
            // ユーザー情報を表示
            child: Text('ログイン情報：${user!.displayName}=====1'),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserLogin()));
              /* --- 省略 --- */
            },
          ),
          bottomNavigationBar: Footer(),
        );

      case 2:
        return Scaffold(
          appBar: const Header(),
          body: Center(
            // ユーザー情報を表示
            child: Text('ログイン情報：${user!.displayName}====2'),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserLogin()));
              /* --- 省略 --- */
            },
          ),
          bottomNavigationBar: Footer(),
        );

      default:
        return Scaffold(
          appBar: AppBar(
            title: const Text(''),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // ログアウト処理
                  // 内部で保持しているログイン情報等が初期化される
                  // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
                  // await FirebaseAuth.instance.signOut();
                  // ログイン画面に遷移＋チャット画面を破棄
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return const UserLogin();
                    }),
                  );
                },
              ),
            ],
          ),
          body: Center(
            // ユーザー情報を表示
            child: Text('ログイン情報：${user!.displayName}'),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserLogin()));
              /* --- 省略 --- */
            },
          ),
          bottomNavigationBar: Footer(),
        );
    }
  }
}
