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

class geininProfile extends StatelessWidget {

  String? documentId;
  List tag = [];
  bool isOn = false;
  String shoukai ;
  String url =""; 
  String userName = "";
  String unitName = "";

   geininProfile(this.shoukai){
  }
  
  // String userId = "";
  // final User?
  User? user = FirebaseAuth.instance.currentUser;
      Stream<Image> getAvatarUrlForProfile() async* {
          final ref =  FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
      // no need of the file extension, the name will do fine.
          var url = await ref.getDownloadURL();
          // print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
          // print(url);
          yield Image.network(
          url,
          width: 300,
          height: 300,);
      }

void aikataEdit() async{
    final userGid =await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid).get();

    final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);
    // T02_Geininの自分のdocumentIdを取得
    await FirebaseFirestore.instance
        .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
      (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach(
            (doc) {
              documentId=doc.id;
            },
          ),
        });
    final ref = await FirebaseFirestore.instance.collection('T02_Geinin').doc(documentId).get();
          // print(ref.data()!["T05_VideoUrl"]);
    final ref2 =  FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
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
                            context, MaterialPageRoute(builder: (context) => geininInfoEdit(shoukai,url,userName,unitName)));
                      } catch (e) {}
                    },
                    child: const Text('芸人情報編集'),
                  ),
            ElevatedButton(
                    onPressed: () async {
                      try {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => AikataBosyu(tag,isOn)));
                      } catch (e) {}
                    },
                    child: const Text('相方募集設定'),
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
                child: Text('ログアウト')
                ),
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
                    length: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:  [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text("aaaaaaaaaaaaa"),
                              StreamBuilder(stream: getAvatarUrlForProfile(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                      if(snapshot.connectionState == ConnectionState.waiting){
                                        return const Text("no photo");
                                      }else if (snapshot.hasData){
                                        Image photo = snapshot.data!;
                                        return  photo;
                                      } else {
                                        return const Text("not photo");
                                      }
                                      },),
                                        Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text('プロフィール名：${user!.displayName}====2'),
                                              // Text("$shoukai"),
                                              Container(
                                                  padding: const EdgeInsets.all(5.0),
                                                  width: 500,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.black),
                                                  ),
                                                  child:Column(
                                                          children: [
                                                            Text("$shoukai"),
                                                          ],
                                                        ),
                                                ),
                                            ],
                                          ),
                                    
                            ],),
                          TabBar(
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.black12,
                              tabs: [Tab(text: "マイリスト"), Tab(text: "投稿")]),
                          Expanded(
                              child: TabBarView(
                                  physics: NeverScrollableScrollPhysics(),
                                  children: <Widget>[
                                mylist(),
                                geininToukou(),
                              ]))
                        ]
                        )
                        )
                        ),
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
    final msg =
        await FirebaseFirestore.instance.collection('T01_Person').doc(uid).delete();
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
