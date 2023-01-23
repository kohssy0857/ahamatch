import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../parts/MoviePlayerWidget .dart';

class ShinmeResult extends StatefulWidget {
  ShinmeResult({Key? key}) : super(key: key);
  @override
  _ShinmeResultState createState() => _ShinmeResultState();
}

class _ShinmeResultState extends State<ShinmeResult> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> bosyuList = [];
  // ドキュメント情報を入れる箱を用意
  List documentList = [];
  List toukouDocId = [];
  List unitNameList = [];
  List shinmeToukouList = [];
  List secretList = [];
  List toukousyaId = [];
  var name = 'こんぶ';

    Stream<List> getVideo() async* {
      // final ref =  FirebaseStorage.instance.ref().child('post/shinme/マルセロ1.mp4');
      // 自身がフォローしている相手のidを取得
      await FirebaseFirestore.instance.collection('T01_Person').doc(user!.uid).collection("Follow").get().
    then((QuerySnapshot snapshot) async  {
      if(snapshot.docs.isNotEmpty){
        snapshot.docs.forEach((doc) {
     documentList.add(doc.get('T05_GeininId'));
   });
  }
});
      if(documentList.isNotEmpty==true){
        // フォローしているリストを使用し、T05_Toukouの中のT05_VideoUrlを取得しリストに入れる
      await FirebaseFirestore.instance.collection('T05_Toukou').where("T05_Geinin", whereIn: documentList).get().
    then((QuerySnapshot snapshot) {
   snapshot.docs.forEach((doc) {
    if(doc["T05_Type"]==3){
      if(toukouDocId.contains(doc.id)==false){
        toukouDocId.add(doc.id);
      bosyuList.add(doc["T05_Bosyu"]);
      unitNameList.add(doc["T05_UnitName"]);
      shinmeToukouList.add(doc["T05_Toukou"]);
      secretList.add(doc["T05_Secret"]);
      // print("チョモランマーーーーーーーーーー");
      // print(doc["T05_ToukouId"]);
      // print(user!.uid);
      toukousyaId.add(doc["T05_ToukouId"]);
      }
    }
   });
});

      final all = await  FirebaseStorage.instance.ref().child('post/neta/').listAll();
      yield bosyuList;
      }
}

  Widget build(BuildContext context) {
    return 
    StreamBuilder(stream: getVideo(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("新芽ないよ");
                    }else if (snapshot.hasData){
                      List photo = snapshot.data!;
                          return Column(
                                children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                      // padding: EdgeInsets.all(250),
                                    itemCount: bosyuList.length,
                                    itemBuilder: (context, index){
                                      if(secretList[index]==0 || toukousyaId[index]==user!.uid){
                                        return  Column(
                                        children: [
                                          // if(secretList[index]){
                                            
                                          // },
                                          Text("${unitNameList[index]}"),
                                          ElevatedButton(
                                              onPressed: () async {
                                                final result = await DialogUtils.showEditingDialog(context, shinmeToukouList[index],toukouDocId[index]);
                                                // setState(() {
                                                // });
                                              },
                                              child: Card(
                                          child: ListTile(
                                            // leading: Image.network(T02_Convention[index].T06_image),
                                            title: Text("リクエスト："+bosyuList[index]),
                                            subtitle: Text("原稿："+shinmeToukouList[index]), // 商品名
                                          ),
                                        ),
                                            ),
                                          
                                        ],
                                      );
                                      }
                                      return  Column(
                                        children: [
                                        ],
                                      );
                                      // Card(
                                      //     child: ListTile(
                                      //       // leading: Image.network(T02_Convention[index].T06_image),
                                      //       title: Text(bosyuList[index]),
                                      //       subtitle: Text(unitNameList[index]), // 商品名
                                      //     ),
                                      //   );
                                      
                                    }
                                      )
                                  
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
                    },);
  }
}


class DialogUtils {
  DialogUtils._();

  /// 入力した文字列を返すダイアログを表示する
  static Future<String?> showEditingDialog(
    BuildContext context,
    String text,
    String id
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(text: text,id:id);
      },
    );
  }
}

/// 状態を持ったダイアログ
class TextEditingDialog extends StatefulWidget {
  const TextEditingDialog({Key? key, this.text,this.id}) : super(key: key);
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
          controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
        }
      },
    );
  }

  // FirebaseFirestoreに対して削除を促している関数
  Future ShinmeToukou(String toukou, String? id) {
    final doc = FirebaseFirestore.instance
        .collection('T05_Toukou') // コレクションID
        .doc(id);

    return doc.update({
      "T05_Secret":1,
      "T05_Toukou": toukou,
      "T05_ToukouId" : user!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: 
      Form(
            key: formKey,
            child: 
                TextFormField(
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
            if (formKey.currentState!.validate()){
                Navigator.of(context).pop(controller.text);
                ShinmeToukou(controller.text,widget.id);
            }
          },
          child: const Text('完了'),
        )
      ],
    );
  }
}

