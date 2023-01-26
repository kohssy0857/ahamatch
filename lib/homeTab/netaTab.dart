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
import '../parts/FullscreenVideo.dart';
// void senddNeta() {}

class netaResult extends StatefulWidget {
  netaResult({Key? key}) : super(key: key);
  // Home(){
  // }
  @override
  _netaResultState createState() => _netaResultState();
}

class _netaResultState extends State<netaResult> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoThumbnails = [];
  List<String> videoShoukai = [];
  List<String> videoId = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List<String> videoTitle = [];

  Stream<List> getVideo() async* {
    // ---------------------------------------------------------------
    final ref = FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
    // 自身がフォローしている相手のidを取得
    await FirebaseFirestore.instance
        .collection('T01_Person')
        .doc(user!.uid)
        .collection("Follow")
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          documentList.add(doc.get('T05_GeininId'));
        });
      }
    });

    if (documentList.isNotEmpty == true) {
      documentList = documentList.toSet().toList();
      // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
      await FirebaseFirestore.instance
          .collection('T05_Toukou')
          .where("T05_Geinin", whereIn: documentList)
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) {
          if (doc["T05_Type"] == 1) {
            if (videoThumbnails.contains(doc["T05_Thumbnail"]) == false) {
              videoThumbnails.add(doc["T05_Thumbnail"]);
              videoShoukai.add(doc["T05_Shoukai"]);
              videoId.add(doc.id);
              videoTitle.add(doc["T05_Title"]);
            }
          }
        });
      });

      final all =
          await FirebaseStorage.instance.ref().child('post/neta/').listAll();

      yield videoThumbnails;
    }

    // -------------------------------------------------

    // 取得した動画URLのリストを
    // var url = await ref.getDownloadURL();
    // videoUrls.add(ref.toString());

    // final ref = await FirebaseFirestore.instance.collection('T05_Toukou').doc("7NOSPf1J3DAQvEvwimAE").get();
    // // print(ref.data()!["T05_VideoUrl"]);
    // videoUrls.add(ref.data()!["T05_VideoUrl"]);
    yield videoThumbnails;
  }

  @override
  Widget build(BuildContext context) {
    return
        // Text("Left"),
        StreamBuilder(
      stream: getVideo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ネタないよ");
        } else if (snapshot.hasData) {
          List photo = snapshot.data!;
          return Column(
            children: [
              Text("ログイン情報:${user!.displayName}"),
              Expanded(
                  child: SizedBox(
                      child: ListView.builder(
                          shrinkWrap: true,
                          // padding: EdgeInsets.all(250),
                          itemCount: videoThumbnails.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text("タイトル：" + "${videoTitle[index]}"),
                                Image.network(
                                  photo[index],
                                  width: 500,
                                  height: 250,
                                ),

                                // MoviePlayerWidget(photo[index],videoId[index])
                                // MoviePlayerWidget(photo[index],"7NOSPf1J3DAQvEvwimAE")
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 500,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: Text(
                                          "概要：" + "${videoShoukai[index]}"),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final result =
                                            await DialogUtils.showEditingDialog(
                                                context, videoId[index]);
                                        // setState(() {
                                        //   // shinmeToukouList[index] = result ?? shinmeToukouList[index];
                                        // });
                                      },
                                      icon: Icon(Icons.textsms),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FullscreenVideo(
                                                        videoId[index],
                                                        100,
                                                        99))).then((value) {
                                          // 再描画
                                          setState(() {});
                                        });
                                        ;
                                      },
                                      icon: Icon(Icons.fullscreen),
                                    ),
                                  ],
                                )
                              ],
                            );
                          }))),
            ],
          );
        } else {
          return Column(
            children: [
              Text("ログイン情報:${user!.displayName}"),
              Text("芸人をフォローしてください"),
            ],
          );
          // return const Text("not photo");
        }
      },
    );
    // bottomNavigationBar: Footer(),
  }
}

class DialogUtils {
  DialogUtils._();

  /// 入力した文字列を返すダイアログを表示する
  static Future<String?> showEditingDialog(
      BuildContext context, String id) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(id: id);
      },
    );
  }
}

/// 状態を持ったダイアログ
class TextEditingDialog extends StatefulWidget {
  const TextEditingDialog({Key? key, this.text, this.id}) : super(key: key);
  final String? text;
  final String? id;

  @override
  State<TextEditingDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<TextEditingDialog> {
  final user = FirebaseAuth.instance.currentUser;
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // TextFormFieldに初期値を代入する
    controller.text = widget.text ?? '';
    // id = widget.id ?? '';
    focusNode.addListener(
      () {
        // フォーカスが当たったときに文字列が選択された状態にする
        if (focusNode.hasFocus) {
          controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.text.length);
        }
      },
    );
  }

  // FirebaseFirestoreに対して削除を促している関数
  void ShinmeToukou(String toukou, String? id) {
    final mylistcheck = FirebaseFirestore.instance
        .collection("T05_Toukou")
        .doc(id)
        .collection("coments");
    mylistcheck.get().then((docSnapshot) async => {
          // 存在しない場合、フォローを行う
          await FirebaseFirestore.instance
              .collection('T05_Toukou')
              .doc(id)
              .collection("coments")
              .doc()
              .set({
            "User": user!.displayName,
            "Coment": toukou,
            "Create": Timestamp.fromDate(DateTime.now()),
          }),
          print("登録できました"),
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true, // ダイアログが開いたときに自動でフォーカスを当てる
          focusNode: focusNode,
          controller: controller,
          onFieldSubmitted: (_) {
            // エンターを押したときに実行される
            Navigator.of(context).pop(controller.text);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '入力されていません';
            }
            return null;
          },
        ),
      ),
      // TextFormField(
      //   autofocus: true, // ダイアログが開いたときに自動でフォーカスを当てる
      //   focusNode: focusNode,
      //   controller: controller,
      //   onFieldSubmitted: (_) {
      //     // エンターを押したときに実行される
      //     Navigator.of(context).pop(controller.text);
      //   },
      //   validator: (value) {
      //         if (value == null || value.isEmpty) {
      //           return '入力されていません';
      //         }
      //         return null;
      //       },
      // ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop(controller.text);
              ShinmeToukou(controller.text, widget.id);
            }
          },
          child: const Text('送信'),
        ),
      ],
    );
  }
}
