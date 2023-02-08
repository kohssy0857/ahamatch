import 'package:ahamatch/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Notification.dart';
import 'footer.dart';
import 'Search.dart';
import 'package:intl/intl.dart';

import 'Billing.dart';

class Header extends StatefulWidget with PreferredSizeWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  _Header createState() => _Header();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Header extends State<Header> {
  bool _searchBoolean = false;
  final User? user = FirebaseAuth.instance.currentUser;
  bool unread = false;
  bool notfiExist = false;
  int notfiLen = 0;
  List notfiList = [];
  List refList = [];

  Future<String> fetchCoin() async {
    final docs = await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var data = docs.exists ? docs.data() : null;

    var ndocref = await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Notification")
        .orderBy("Create", descending: true);
    var ndoc = await ndocref.get();

    print(ndoc.size);
    notfiLen = ndoc.size;
    if (ndoc.size == 0) {
    } else {
      notfiExist = true;
      for (var element in ndoc.docs) {
        refList.add(element);
        if (element["unread"]) {
          unread = true;
          // refList.add(element);
          // var el=   element.reference;
        }
      }
      // var ref = await FirebaseFirestore.instance
      //     .collection("T01_Person")
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .collection("Notification");
      // ref.doc().update({"unread": false});
    }

    return data!['T01_AhaCoin'].toString();
  }

  String DateFormat(Timestamp stamp) {
    var date = stamp.toDate();
    var now = DateTime.now();
    int diff = now.difference(date).inMinutes;
    if (diff > 1440) {
      return "${date.month}月${date.day}日";
    } else if (diff > 60) {
      return "${(diff / 60).floor()}時間前";
    } else {
      return "$diff分前";
    }
  }

  String _coin = "";
  int i = 0;
  final _editController = TextEditingController();
  // final docs = FirebaseFirestore.instance.collection('T01_Person').doc(FirebaseAuth.instance.currentUser!.uid).get();
  //final coin = fetchCoin();

  @override
  Widget build(BuildContext context) {
    // final docSnapshot = FirebaseFirestore.instance.collection('T01_Person').doc(user!.uid).get();

    fetchCoin().then(
      (value) {
        // _coin = value.toString();
        if (i == 0) {
          setState(() {
            _coin = value.toString();
            i++;
          });
        }
      },
    );
    return AppBar(
        title: !_searchBoolean
            ? GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Footer()));
                },
                child: const Text(
                  'アハマッチ!',
                ),
              )
            : searchTextField(),
        // ヘッダーカラー
        backgroundColor: const Color.fromARGB(255, 255, 166, 077),
        actions: !_searchBoolean
            ? [
                IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    //   onPressed: () async {
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => SearchResultMane()));},
                    onPressed: () {
                      setState(() {
                        _searchBoolean = true;
                      });
                    }),
                TextButton.icon(
                  icon: const Icon(Icons.monetization_on),
                  label: Text(_coin),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.brown,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Billing()));
                  },
                ),
                IconButton(
                    icon: unread
                        ? const Icon(
                            Icons.notification_important_outlined,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.notifications,
                            color: Colors.brown,
                          ),
                    onPressed: () {
                      for (var Q in refList) {
                        Q.reference.update({"unread": false});
                      }
                      setState(() {
                        unread = false;
                      });
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: const Text("通知"),
                              insetPadding: notfiExist
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 80, vertical: 100)
                                  : const EdgeInsets.symmetric(
                                      horizontal: 40.0, vertical: 24.0),
                              children: [
                                notfiExist
                                    ? SizedBox(
                                        width: 600,
                                        height: 800,
                                        child: ListView.separated(
                                          padding:
                                              const EdgeInsets.only(bottom: 0),
                                          shrinkWrap: true,
                                          itemCount: notfiLen,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              title:
                                                  Text(refList[index]["Text"]),
                                              subtitle: Text(DateFormat(
                                                  refList[index]["Create"])),
                                              isThreeLine: true,
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return const Divider();
                                          },
                                        ),
                                      )
                                    : const Text("通知はありません"),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("閉じる"))
                              ],
                            );
                          });

                      // await Navigator.push(
                      //               // ボタン押下でオーディション編集画面に遷移する
                      //                 context, MaterialPageRoute(builder: (context) => NotificationMane()));
                    }),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.brown,
                  ),
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
                ),
              ]
            : [
                IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = false;
                      });
                    })
              ]);
  }

  Widget searchTextField() {
    //検索バーの見た目
    return TextField(
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      controller: _editController,
      style: const TextStyle(
        //テキストのスタイル
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
      onSubmitted: ((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  // SearchResult(_editController.text)
                  SearchResult(_editController.text),
            ));
      }),
      decoration: const InputDecoration(
        //TextFiledのスタイル
        enabledBorder: UnderlineInputBorder(
            //デフォルトのTextFieldの枠線
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(
            //TextFieldにフォーカス時の枠線
            borderSide: BorderSide(color: Colors.white)),
        hintText: 'Search', //何も入力してないときに表示されるテキスト
        hintStyle: TextStyle(
          //hintTextのスタイル
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }
}
