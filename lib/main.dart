//  DB保存表示
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(
//     const MyApp(),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyWidget(),
//     );
//   }
// }

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Container(
//                 height: double.infinity,
//                 alignment: Alignment.topCenter,
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('dream')
//                       .orderBy('createdAt')
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       return const Text('エラーが発生しました');
//                     }
//                     if (!snapshot.hasData) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     final list = snapshot.requireData.docs
//                         .map<String>((DocumentSnapshot document) {
//                       final documentData =
//                           document.data()! as Map<String, dynamic>;
//                       return documentData['content']! as String;
//                     }).toList();

//                     final reverseList = list.reversed.toList();

//                     return ListView.builder(
//                       itemCount: reverseList.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return Center(
//                           child: Text(
//                             reverseList[index],
//                             style: const TextStyle(fontSize: 20),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     autofocus: true,
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     final document = <String, dynamic>{
//                       'content': _controller.text,
//                       'createdAt': Timestamp.fromDate(DateTime.now()),
//                     };
//                     FirebaseFirestore.instance
//                         .collection('dream')
//                         .doc()
//                         .set(document);
//                     setState(_controller.clear);
//                   },
//                   child: const Text('送信'),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// 認証
import 'package:ahamatch/parts/footer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'home/home.dart';
import 'login/login.dart';
import 'login/signup.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login/UserInput.dart';
import 'functions.dart';
import 'home/SysHome.dart';

Future<void> main() async {
  // ウィジェット初期化
  WidgetsFlutterBinding.ensureInitialized();

  // firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ストレージの初期化有効化
  final storage = FirebaseStorage.instance;
  final storageRef = FirebaseStorage.instance.ref();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter app',
        // 背景しょく
        theme: ThemeData(
          appBarTheme:
              AppBarTheme(backgroundColor: Color.fromARGB(255, 255, 166, 077)),
          scaffoldBackgroundColor: Color.fromARGB(255, 255, 219, 153),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              elevation: 10,
              shadowColor: Colors.grey,
            ),
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // ユーザーの宣言
            User? user = FirebaseAuth.instance.currentUser;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }
            // ログイン情報があるなら
            if (snapshot.hasData) {
              // FirebaseAuth.instance.signOut();
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(user.toString()),
              //   ),
              // );
              // ユーザーの詳細情報が入力されていないなら
              if (user!.photoURL == null) {
                // ユーザー情報入力ページへ
                return const UserInput();
                // ないなら
              } else if (snapshot.data!.displayName!.contains("-") == true) {
                return SysHome();
              } else {
                print("Footer東リマース");
                return Footer();
              }
            }
            // User が null である、つまり未サインインのサインイン画面へ
            return const UserLogin();
          },
        ),
      );
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: "/",
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyAuthPage(),
//     );
//   }
// }

// class MyAuthPage extends StatefulWidget {
//   @override
//   _MyAuthPageState createState() => _MyAuthPageState();
// }

// class _MyAuthPageState extends State<MyAuthPage> {
//   // 入力されたメールアドレス
//   String newUserEmail = "";
//   // 入力されたパスワード
//   String newUserPassword = "";
//   // 登録・ログインに関する情報を表示
//   String infoText = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           padding: EdgeInsets.all(32),
//           child: Column(
//             children: <Widget>[
//               TextFormField(
//                 // テキスト入力のラベルを設定
//                 decoration: InputDecoration(labelText: "メールアドレス"),
//                 onChanged: (String value) {
//                   setState(() {
//                     newUserEmail = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 decoration: InputDecoration(labelText: "パスワード（６文字以上）"),
//                 // パスワードが見えないようにする
//                 obscureText: true,
//                 onChanged: (String value) {
//                   setState(() {
//                     newUserPassword = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     // メール/パスワードでユーザー登録
//                     final FirebaseAuth auth = FirebaseAuth.instance;
//                     final UserCredential result =
//                         await auth.createUserWithEmailAndPassword(
//                       email: newUserEmail,
//                       password: newUserPassword,
//                     );

//                     // 登録したユーザー情報
//                     final User user = result.user!;
//                     setState(() {
//                       infoText = "登録OK：${user.email}";
//                     });
//                   } catch (e) {
//                     // 登録に失敗した場合
//                     setState(() {
//                       infoText = "登録NG：${e.toString()}";
//                     });
//                   }
//                 },
//                 child: Text("ユーザー登録"),
//               ),
//               const SizedBox(height: 8),
//               Text(infoText)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
