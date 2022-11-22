import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import "../home/home.dart";
import '../main.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLogin createState() => _UserLogin();
}

class _UserLogin extends State<UserLogin> {
  final _auth = FirebaseAuth.instance;
  

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                email = value;
              },
              decoration: const InputDecoration(
                hintText: 'メールアドレスを入力',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'パスワードを入力',
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('ログイン'),
            onPressed: () async {
              try {
                final newUser = await _auth.signInWithEmailAndPassword(
                    email: email, password: password);
                if (newUser != null) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => App()));
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'invalid-email') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(''),
                    ),
                  );
                  print('メールアドレスのフォーマットが正しくありません');
                } else if (e.code == 'user-disabled') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('現在指定したメールアドレスは使用できません'),
                    ),
                  );
                  print('現在指定したメールアドレスは使用できません');
                } else if (e.code == 'user-not-found') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('指定したメールアドレスは登録されていません'),
                    ),
                  );
                  print('指定したメールアドレスは登録されていません');
                } else if (e.code == 'wrong-password') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('パスワードが間違っています'),
                    ),
                  );
                  print('パスワードが間違っています');
                }
              }
            },
          ),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Register()));
              },
              child: Text('新規登録はこちらから')),
              // メールアドレスを入力後、パスワードリセットボタンを押下
          ElevatedButton(
                  child: const Text('パスワードリセット'),
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('パスワードリセット用のメールを送信しました。確認してください'),
                        ),
                      );
                      print("パスワードリセット用のメールを送信しました");
                    } on FirebaseAuthException catch (e) {
                        if (e.code == 'invalid-email') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('メールアドレスのフォーマットが正しくありません'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          print('メールアドレスのフォーマットが正しくありません');
                        } 
                } catch (e) {
                      print(e);
                    }
                  })
        ],
      ),
    );
  }
}

// class MainContent extends StatefulWidget {
//   const MainContent({Key? key}) : super(key: key);

//   @override
//   _MainContentState createState() => _MainContentState();
// }

// class _MainContentState extends State<MainContent> {
//   //ステップ１
//   final _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('成功'),
//         actions: [
//           IconButton(
//             //ステップ２
//             onPressed: () async {
//               Navigator.push(
//                   context, MaterialPageRoute(builder: (context) => Home()));
//             },
//             icon: Icon(Icons.close),
//           ),
//         ],
//       ),
//     );
//   }
// }
