import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "../home/home.dart";
import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //ステップ１
  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
  final _formKey = GlobalObjectKey<FormState>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('新規登録'),
        ),
        key: _formKey,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'メールアドレスを入力',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'パスワードを入力',
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text('新規登録'),
                //ステップ２
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null && !user.emailVerified) {
                        await user.sendEmailVerification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('認証メールを送信しました。確認してください'),
                          ),
                        );
                      }
                      if (newUser != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserLogin()));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'email-already-in-use') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('指定したメールアドレスは登録済みです'),
                          ),
                        );
                        print('指定したメールアドレスは登録済みです');
                      } else if (e.code == 'invalid-email') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('メールアドレスのフォーマットが正しくありません'),
                          ),
                        );
                        print('メールアドレスのフォーマットが正しくありません');
                      } else if (e.code == 'operation-not-allowed') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('指定したメールアドレス・パスワードは現在使用できません'),
                          ),
                        );
                        print('指定したメールアドレス・パスワードは現在使用できません');
                      } else if (e.code == 'weak-password') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('パスワードは６文字以上にしてください'),
                          ),
                        );
                        print('パスワードは６文字以上にしてください');
                      }
                    }
                  }
                },
              )
            ],
          ),
        ));
  }
}
