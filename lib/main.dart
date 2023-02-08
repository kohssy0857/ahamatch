
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
          fontFamily: "Noto Sans JP",
          appBarTheme:
              AppBarTheme(backgroundColor: Colors.brown),
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

