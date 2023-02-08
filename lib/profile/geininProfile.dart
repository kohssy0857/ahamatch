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
import 'geininInfoEdit.dart';
import 'mylist.dart';
import 'geininToukou.dart';
import 'geininShinme.dart';
import 'geininAhapuchi.dart';
import 'geininKokuchi.dart';
import 'package:flutter/services.dart';

class geininProfile extends StatelessWidget {
  String? documentId;
  List tag = [];
  bool isOn = false;
  String shoukai;
  String url = "";
  String userName = "";
  String unitName = "";
  int coin = 0;
  int userCoin = 0;
  int bill = 0;

  geininProfile(this.shoukai) {}

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
    // print(ref.data()!["T05_VideoUrl"]);
    final ref2 =
        FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
    // no need of the file extension, the name will do fine.
    url = await ref2.getDownloadURL();
    tag = ref.data()!["T02_Tags"];
    isOn = ref.data()!["T02_PartnerRecruit"];
    shoukai = await ref.data()!["T02_describe"];
    userName = userGid.data()!["T01_DisplayName"];
    unitName = ref.data()!["T02_UnitName"];
  }

  @override
  Widget build(BuildContext context) {
    aikataEdit();
    nameCut(user!.displayName);
    return Scaffold(
      appBar: const Header(),
      drawer: Drawer(
        child: Column(
          children: [
            const ListTile(title: Text("")),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => geininInfoEdit(
                              shoukai, url, userName, unitName)));
                } catch (e) {}
              },
              child: const Text('芸人情報編集'),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AikataBosyu(tag, isOn)));
                } catch (e) {}
              },
              child: const Text('相方募集設定'),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: const Text("現金化"),
                            content: TextField(
                                onChanged: (value) {
                                  if (double.tryParse(value) != null) {
                                    coin = int.parse(value);
                                  }
                                },
                                maxLength: 7,
                                decoration: const InputDecoration(
                                  hintText: "現金化するアハコインを入力",
                                  icon: Icon(Icons.copyright_rounded),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ]),
                            actions: <Widget>[
                              TextButton(
                                child: const Text(
                                  "キャンセル",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                  child: const Text(
                                    "現金化",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  onPressed: () {
                                    bill = (coin / 3).floor();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              title: const Text("現金化"),
                                              content: Text(
                                                  "$coinアハコインを$bill円に現金化します"),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text(
                                                    "戻る",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                    onPressed: () async {
                                                      final docs =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'T01_Person')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid)
                                                              .get();
                                                      var data = docs.exists
                                                          ? docs.data()
                                                          : null;
                                                      userCoin =
                                                          data!["T01_AhaCoin"];

                                                      if (coin <= 2) {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      content:
                                                                          const Text(
                                                                              "現金化できるのは3ポイントからです"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("戻る"))
                                                                      ],
                                                                    ));
                                                      } else if (userCoin <
                                                          coin) {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      content:
                                                                          const Text(
                                                                              "所持コインが足りません"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("戻る"))
                                                                      ],
                                                                    ));
                                                      } else {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'T01_Person')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .update({
                                                          "T01_AhaCoin":
                                                              userCoin - coin
                                                        });
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "$coinポイントを現金化しました"),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          "確認"))
                                                                ],
                                                              );
                                                            });
                                                      }
                                                    },
                                                    child: const Text("確認"))
                                              ]);
                                        });
                                  }),
                            ]);
                      });
                },
                child: const Text('アハコイン現金化')),
            const SizedBox(
              height: 30,
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
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
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
                child: const Text('アカウント削除')),
          ],
        ),
      ),
      body: SafeArea(
          child: DefaultTabController(
              length: 5,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('プロフィール名：${nameCut(user!.displayName)}'),
                            // Text("$shoukai"),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              width: 500,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  Text("$shoukai"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.black12,
                        tabs: [Tab(text: "マイリスト"), Tab(text: "ネタ"),Tab(text: "アハプチ"),Tab(text: "新芽"),Tab(text: "告知")]),
                    Expanded(
                        child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: <Widget>[
                          mylist(),
                          geininToukou(),
                          geininAhapuchi(),
                          geininShinme(),
                          geininKokuchi()
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
      title: const Text('　　アカウント削除'),
      children: [
        const Text("          本当にアカウントを削除しますか"),
        SimpleDialogOption(
          child: const Text('削除'),
          onPressed: () async {
            deleteUser();
            print('ユーザーを削除しました!');
          },
        ),
        SimpleDialogOption(
          child: const Text('キャンセル'),
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

String nameCut(String? s) {
  if (s!.contains("#")) {
    return s.substring(0, s.indexOf("#"));
  } else if (s.contains("@")) {
    return s.substring(0, s.indexOf("@"));
  } else {
    return "";
  }
}
