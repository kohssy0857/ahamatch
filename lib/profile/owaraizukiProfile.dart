import 'dart:ffi';

import 'package:ahamatch/home/AuditionInput.dart';
import 'package:ahamatch/profile/mylist.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';

import '../parts/header.dart';
import 'mylist.dart';
import 'aikataBosyu.dart';
import 'mylist.dart';
import 'owaraizukiInfoEdit.dart';

class owaraizukiProfile extends StatelessWidget {
  String? documentId;
  String url = "";
  String userName = "";
  String unitName = "";

  // String userId = "";
  // final User?
  User? user = FirebaseAuth.instance.currentUser;
  Stream<Image> getAvatarUrlForProfile() async* {
    final ref =
        FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
    // no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();
    // print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    // print(url);
    yield Image.network(
      url,
      width: 300,
      height: 300,
    );
  }

  void owaraizukiEdit() async {
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
    // print(ref.data()!["T05_VideoUrl"]);
    final ref2 =
        FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
    // no need of the file extension, the name will do fine.
    url = await ref2.getDownloadURL();
    // shoukai = await ref.data()!["T02_describe"];
    userName = userGid.data()!["T01_DisplayName"];
  }

  @override
  Widget build(BuildContext context) {
    owaraizukiEdit();
    return Scaffold(
      appBar: Header(),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(title: Text("")),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              owaraizukiInfoEdit(url, userName)));
                } catch (e) {}
              },
              child: const Text('お笑い好き情報編集'),
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
                child: Text('ログアウト')),
            ElevatedButton(
                onPressed: () async {
                  final String? selectedText = await showDialog<String>(
                      context: context,
                      builder: (_) {
                        return SimpleDialogSample();
                      });
                  print('ユーザーを削除しました!');
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => GroupInfoPage()));
                },
                child: Text('アカウント削除')),
          ],
        ),
      ),
      body: SafeArea(
          child: DefaultTabController(
              length: 1,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: Text("ログイン情報:${user!.displayName}")),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text("aaaaaaaaaaaaa"),
                        StreamBuilder(
                          stream: getAvatarUrlForProfile(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("no photo");
                            } else if (snapshot.hasData) {
                              Image photo = snapshot.data!;
                              return SizedBox(
                                width: 200,
                                height: 200,
                                child: photo,
                              );
                            } else {
                              return const Text("not photo");
                            }
                          },
                        ),
                        new Flexible(
                          child: Column(
                            children: [
                              Text('プロフィール名：${user!.displayName}====1'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TabBar(
                        labelColor: Colors.brown,
                        unselectedLabelColor: Colors.black12,
                        tabs: [Tab(text: "マイリスト")]),
                    Expanded(
                        child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                          mylist(),
                        ]))
                  ]))),
    );
  }
}

class SimpleDialogSample extends StatefulWidget {
  SimpleDialogSample({Key? key}) : super(key: key);

  @override
  State<SimpleDialogSample> createState() => _SimpleDialogSampleState();
}

class _SimpleDialogSampleState extends State<SimpleDialogSample> {
  // アカウント削除
  void deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final msg = await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(uid)
        .delete();
    // ユーザーを削除
    await user?.delete();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return const UserLogin();
      }),
    );
    print('ユーザーを削除しました!');
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('　　アカウント削除'),
      children: [
        Text("          本当にアカウントを削除しますか"),
        SimpleDialogOption(
          child: Text('削除'),
          onPressed: () async {
            deleteUser();
            print('ユーザーを削除しました!');
          },
        ),
        SimpleDialogOption(
          child: Text('キャンセル'),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => HomePage()));
            print('キャンセルされました!');
          },
        )
      ],
    );
  }
}
