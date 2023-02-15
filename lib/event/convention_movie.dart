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
import 'convention_fulscr.dart';
import '../parts/searchAccount.dart';
import 'convention_list.dart';
// void senddNeta() {}

class netaCon extends StatefulWidget {
  final List events;
  final int index;
  netaCon({
    Key? key,
    required this.events,
    required this.index,
  }) : super(key: key);
  // Home(){
  // }
  @override
  _netaConState createState() => _netaConState();
}

class _netaConState extends State<netaCon> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> videoThumbnails = [];
  List<String> videoShoukai = [];
  List<String> videoId = [];
  List<String> userImageList = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List geininIdList = [];
  List movieList = [];
  Map<String, String> geininUnitNameList = {};
  List<String> videoTitle = [];
  List userImage = [];

  Stream<List> getVideo() async* {
    // ---------------------------------------------------------------

    // final ref = FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
    final task = await FirebaseStorage.instance.ref("profile/${user!.uid}.jpg");
    // print("画像のURL");
    // print("${task.fullPath}");
    userImage.add(task.getDownloadURL());
    // print("画像のURL");
    // print("${userImage}");
    // final gid =
    //     FirebaseFirestore.instance.collection("T01_Person").doc(user!.uid);
    //         });

    // 自身がフォローしている相手のidを取得
    await FirebaseFirestore.instance
        .collection('T07_Convention')
        .where('T07_ConventionId', isEqualTo: widget.events[widget.index].docid)
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          documentList.add(doc.get('T07_Geinin'));
          movieList.add(doc.get('T07_VideoUrl'));
          geininIdList
              .add(doc.get('T07_Geinin').path.replaceFirst("T02_Geinin/", ""));

          FirebaseFirestore.instance
              .collection('T02_Geinin')
              .doc(
                  "${doc.get('T07_Geinin').path.replaceFirst("T02_Geinin/", "")}")
              .get()
              .then((DocumentSnapshot snapshot) {
            // geininUnitNameList.add(snapshot.get('T02_UnitName'));
            geininUnitNameList[doc.get('T07_Geinin').path.replaceFirst(
                "T02_Geinin/", "")] = snapshot.get('T02_UnitName');
          });
        });
      }
    });
    // print(geininUnitNameList);

    if (documentList.isNotEmpty == true) {
      // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
      for (int i = 0; i < documentList.length; i++) {
        await FirebaseFirestore.instance
            .collection('T05_Toukou')
            .where("T05_Geinin", isEqualTo: documentList[i])
            .where("T05_VideoUrl", isEqualTo: movieList[i])
            .get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((doc) {
            if (doc["T05_Type"] == 1) {
              if (videoThumbnails.contains(doc["T05_Thumbnail"]) == false) {
                geininIdList.add(
                    doc["T05_Geinin"].path.replaceFirst("T02_Geinin/", ""));
                videoThumbnails.add(doc["T05_Thumbnail"]);
                videoShoukai.add(doc["T05_Shoukai"]);
                videoId.add(doc.id);
                videoTitle.add(doc["T05_Title"]);
              }
            }
          });
        });
      }
      yield videoThumbnails;
    }
  }

  // 視聴回数を増やす関数
  void addShityoukaisu(String documentId) {
    FirebaseFirestore.instance
        .collection('T05_Toukou')
        .doc(documentId)
        .update({"T05_ShityouKaisu": FieldValue.increment(1.0)});
    print("視聴回数＋１");
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const Header(),
      body: StreamBuilder(

      stream: getVideo(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ロード中");
        } else if (snapshot.hasData) {
          List photo = snapshot.data!;

          return 
          Column(
            children: [
              Text("${widget.events[widget.index].name}",
                style: TextStyle(
                  fontSize: 60,
                ),),
              Flexible(
                child:
                ListView.builder(
                  shrinkWrap: true,
                  // padding: EdgeInsets.all(250),
                  itemCount: videoThumbnails.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        // Text("${geininUnitNameList[geininIdList[index]]}"),
                        ElevatedButton(
                            onPressed: () async {
                              try {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchResultMane(
                                            word:
                                                "${geininUnitNameList[geininIdList[index]]}",type: 2,)));
                              } catch (e) {}
                            },
                            child: SizedBox(
                              width: 100,
                              child: Text(
                                  '${geininUnitNameList[geininIdList[index]]}'),
                            )),
                        Column(
                          children: [
                            Text("タイトル：" + "${videoTitle[index]}"),
                            SizedBox(
                              width: 300,
                              height: 300,
                              child: Image.network(photo[index],
                                  height: 150, fit: BoxFit.fill),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 500,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Text("概要：" + "${videoShoukai[index]}"),
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
                                    addShityoukaisu(videoId[index]);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ConFullscreenVideo(
                                                    videoId[index],
                                                    100,99,widget.events,index))).then((value) {
                                      // 再描画
                                      setState(() {});
                                    });
                                  },
                                  icon: Icon(Icons.fullscreen),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    );
                  }
                  ),
              )
                ]
              );

        } else {
          return Column(
            children: [
              Text("芸人をフォローしてください"),
            ],
          );
          // return const Text("not photo");
        }
      },
    ));
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
    super.initState();
  }

  // FirebaseFirestoreに対して削除を促している関数
  void ShinmeToukou(String toukou, String? id) {
    final mylistcheck = FirebaseFirestore.instance
        .collection("T05_Toukou")
        .doc(id)
        .collection("Comment");

    mylistcheck.get().then((docSnapshot) async => {
          // 存在しない場合、フォローを行う
          await FirebaseFirestore.instance
              .collection('T05_Toukou')
              .doc(id)
              .collection("Comment")
              .doc()
              .set({
            "User": user!.displayName,
            "Comment": toukou,
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
