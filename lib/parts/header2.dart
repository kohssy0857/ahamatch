import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<String> fetchCoin() async {
    final docs = await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = docs.exists ? docs.data() : null;
    print('out = ' + data!['T01_AhaCoin'].toString());
    return data['T01_AhaCoin'].toString();
  }

  String _coin = "";
  int i = 0;
  // final docs = FirebaseFirestore.instance.collection('T01_Person').doc(FirebaseAuth.instance.currentUser!.uid).get();
  //final coin = fetchCoin();

  @override
  Widget build(BuildContext context) {
    // final docSnapshot = FirebaseFirestore.instance.collection('T01_Person').doc(user!.uid).get();

    fetchCoin().then(
      (value) {
        print(value);
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
        title: !_searchBoolean ? const Text('アハマッチ!') : searchTextField(),
        actions: !_searchBoolean
            ? [
                IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = true;
                      });
                    }),
                TextButton.icon(
                  icon: const Icon(Icons.monetization_on),
                  label: Text(_coin),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      setState(() {});
                    }),
                IconButton(
                  icon: const Icon(Icons.logout),
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
    return const TextField(
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      style: TextStyle(
        //テキストのスタイル
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
      decoration: InputDecoration(
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
