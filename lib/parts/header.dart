import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';

class Header extends StatefulWidget with PreferredSizeWidget {
    const Header({
    Key? key,
  }) : super(key: key);

  @override
  _Header createState() => _Header();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
class _Header extends State<Header> {
  bool _searchBoolean = false;

  Widget _searchTextField() { //検索バーの見た目
    return TextField(
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      style: TextStyle( //テキストのスタイル
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
      decoration: InputDecoration( //TextFiledのスタイル
        enabledBorder: UnderlineInputBorder( //デフォルトのTextFieldの枠線
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: UnderlineInputBorder( //TextFieldにフォーカス時の枠線
          borderSide: BorderSide(color: Colors.white)
        ),
        hintText: 'Search', //何も入力してないときに表示されるテキスト
        hintStyle: TextStyle( //hintTextのスタイル
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: !_searchBoolean ? Text('アハマッチ!') : _searchTextField(),
      actions: !_searchBoolean
        ? [
          IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _searchBoolean = true;
            });
          }),
          IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            setState(() {

            });
          }),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return UserLogin();
                }),
              );
            },
          ),
        ] 
        : [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchBoolean = false;
              });
            }
          )
        ]
    );
  }
}