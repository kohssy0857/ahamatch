import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';

import '../parts/header.dart';

import '../functions.dart';
import '../parts/MoviePlayerWidget .dart';
import 'package:firebase_storage/firebase_storage.dart';

//
import '../homeTab/shinmeTab.dart';
import '../homeTab/netaTab.dart';
import '../homeTab/announceTab.dart';
import '../homeTab/ahapuchiTab.dart';
// void senddNeta() {}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoUrls = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouList = [];

  @override
  Widget build(BuildContext context) {
    switch (devideUser(user)) {
      case 1:
        return Scaffold(
          appBar: const Header(),
          body: Stack(children: <Widget>[
            SafeArea(
                child: DefaultTabController(
                    length: 4,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TabBar(
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.black12,
                              tabs: [
                                Tab(text: "ネタ"),
                                Tab(text: "アハプチ"),
                                Tab(text: "新芽"),
                                Tab(text: "告知")
                              ]),
                          Expanded(
                              child: TabBarView(
                                  physics: NeverScrollableScrollPhysics(),
                                  children: <Widget>[
                                netaResult(),
                                ahapuchiResult(),
                                ShinmeResult(),
                                AnnounceResult(),
                                // Center(child: Text("RIGHT"))
                              ]))
                        ]))),
          ]),
          floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add,
            ),
            backgroundColor: Colors.green,
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const uploadPost()));
              /* --- 省略 --- */
            },
          ),
          // bottomNavigationBar: Footer(),
        );
      case 2:
        return Scaffold(
          appBar: const Header(),
          body: SafeArea(
              child: DefaultTabController(
                  length: 4,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.black12,
                            tabs: [
                              Tab(text: "ネタ"),
                              Tab(text: "アハプチ"),
                              Tab(text: "新芽"),
                              Tab(text: "告知")
                            ]),
                        Expanded(
                            child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                              netaResult(),
                              ahapuchiResult(),
                              ShinmeResult(),
                              AnnounceResult(),
                              // Center(child: Text("RIGHT"))
                            ]))
                      ]))),
          // ユーザー情報を表示
          // Center(child: Text('ログイン情報：${user!.displayName}====2'),),
          // StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          //           if(snapshot.connectionState == ConnectionState.waiting){
          //             return const Text("no photo");
          //           }else if (snapshot.hasData){
          //             List photo = snapshot.data!;
          //                 return Column(
          //                   children: [
          //                     Text("ログイン情報:${user!.displayName}"),
          //                     Expanded(
          //                         child:SizedBox(
          //                             height: 250,
          //                               width: 250,
          //                             child: ListView.builder(
          //                               shrinkWrap: true,
          //                             // padding: EdgeInsets.all(250),
          //                           itemCount: videoUrls.length,
          //                           itemBuilder: (context, index){
          //                             return SizedBox(
          //                               height: 500,
          //                               width: 250,
          //                               child: MoviePlayerWidget(photo[index]),
          //                             );
          //                           }
          //                             )
          //                         )
          //                 ),
          //                   ],
          //                 );
          //           } else {
          //             return Column(
          //               children: [
          //                 Text("ログイン情報:${user!.displayName}"),
          //                 Text("芸人をフォローしてください"),
          //               ],
          //             );
          //             // return const Text("not photo");
          //           }
          //           },),

          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserLogin()));
              /* --- 省略 --- */
            },
          ),
          // bottomNavigationBar: Footer(),
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
          // bottomNavigationBar: Footer(),
        );
    }
  }
}
