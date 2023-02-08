import 'dart:developer';

import 'package:ahamatch/home/SysHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../home/SearchResult.dart';
import '../login/loginFollow.dart';
import '../functions.dart';
import 'geininToukou.dart';
import 'package:flutter/services.dart';

class geininFollowProfile extends StatefulWidget {
  // AuditionManagement画面にあるmodelを取得している
  final model;
  // AuditionManagement画面にあるそれぞれのindex番号を取得している
  final int index;

  String UnitName = "";
  DocumentReference<Map<String, dynamic>> GeininId;

  String PersonId = "";

  geininFollowProfile(this.model, this.index, this.GeininId) {
    UnitName = model.T02_Geinin[index].T02_UnitName;
    PersonId = GeininId.path.replaceFirst("T01_Person/", "");
    // GeininId = model.T02_Geinin[index];
  }

  // const AuditionEdit({Key? key, this.T01_Audition}) : super(key: key);

  @override
  _geininFollowProfile createState() => _geininFollowProfile();
}

class _geininFollowProfile extends State<geininFollowProfile> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  String? documentId;
  String? OkuruDocumentId;
  String? followDocumentId;
  bool isFollwing = false;
  int count = 0;
  bool isOn = false;
  int giftCoin = 0;
  int userCoin = 0;
  int flCoin = 0;
  Future _followKakunin() async {
    final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(widget.PersonId);
    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where('T02_GeininId', isEqualTo: gid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach(
                (doc) {
                  documentId = doc.id;
                },
              ),
            });
    // 今表示している芸人のid=/T02_Geinin/documentIdのリファレンスを確保
    final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);
    final idg = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId)
        .get();
    isOn = idg.data()!["T02_PartnerRecruit"];
    // 自分のフォローコレクションの中に、今表示している芸人が存在するかどうかの確認
    final followcheck = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .collection("Follow")
        .where('T05_GeininId', isEqualTo: id);
    followcheck.get().then((docSnapshot) async => {
          // 存在しない場合、フォローを行う
          if (docSnapshot.docs.isEmpty)
            {
              // 存在する場合、フォローを行う
              if (count == 0)
                {
                  setState(() {
                    count++;
                  }),
                }
            }
          else
            {
              isFollwing = true,
              if (count == 0)
                {
                  setState(() {
                    count++;
                  }),
                }
            }
        });
  }

  Future _Follow() async {
    String userid = "";
    final docRef = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .collection("Follow")
        .doc();
    final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(widget.PersonId);
    // 今表示している芸人のドキュメントIDを確保
    await FirebaseFirestore.instance
        .collection('T02_Geinin')
        .where('T02_GeininId', isEqualTo: gid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach(
                (doc) {
                  documentId = doc.id;
                },
              ),
            });
    // 今表示している芸人のid=/T02_Geinin/documentIdのリファレンスを確保
    final id = await FirebaseFirestore.instance
        .collection("T02_Geinin")
        .doc(documentId);
    // 自分のフォローコレクションの中に、今表示している芸人が存在するかどうかの確認
    final followcheck = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .collection("Follow")
        .where('T05_GeininId', isEqualTo: id);
    followcheck.get().then((docSnapshot) async => {
          // 存在しない場合、フォローを行う
          if (docSnapshot.docs.isEmpty)
            {
              // print("ないよ"),
              await docRef.set({
                'T05_GeininId': id,
              }),
              await FirebaseFirestore.instance
                  .collection('T02_Geinin')
                  .doc(documentId)
                  .update({"T02_Follower": FieldValue.increment(1.0)}),
              setState(() {
                isFollwing = true;
              }),
              // 存在する場合、フォローを行う
            }
          else
            {
              // print("あるよ"),
              await followcheck.get().then((QuerySnapshot querySnapshot) => {
                    querySnapshot.docs.forEach(
                      (doc) {
                        followDocumentId = doc.id;
                      },
                    ),
                  }),
              await FirebaseFirestore.instance
                  .collection("T01_Person")
                  .doc(user!.uid)
                  .collection("Follow")
                  .doc(followDocumentId)
                  .delete(),
              await FirebaseFirestore.instance
                  .collection('T02_Geinin')
                  .doc(documentId)
                  .update({"T02_Follower": FieldValue.increment(-1.0)}),
              setState(() {
                isFollwing = false;
              }),
            }
        });
  }

  // 芸人のT02_GeininからT01_Personを繋ぎ、uidを取得する
  Stream<Image> getAvatarUrlForProfile() async* {
    final ref =
        FirebaseStorage.instance.ref().child('profile/${widget.PersonId}.jpg');
    // no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();
    yield Image.network(
      url,
      width: 300,
      height: 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    _followKakunin();
    return Scaffold(
        appBar: const Header(),
        body: SafeArea(
            child: DefaultTabController(
          length: 1,
          child: Column(
            //RowとStackでも同じ
            children: <Widget>[
              Text('芸名：${widget.UnitName}'),
              // Text(img.toString()),
              StreamBuilder(
                stream: getAvatarUrlForProfile(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("no photo");
                  } else if (snapshot.hasData) {
                    Image photo = snapshot.data!;
                    return photo;
                  } else {
                    return const Text("not photo");
                  }
                },
              ),
              if (isOn)
                const  Text(
                  "相方募集中",
                  style: TextStyle(fontSize: 40),
                ),
              if (isOn == false)
                const  Text(
                  "相方募集をしていない",
                  style: TextStyle(fontSize: 40),
                ),
              isFollwing == false
                  ? ElevatedButton(
                      onPressed: () async {
                        try {
                          _Follow();
                        } catch (e) {}
                      },
                      child: Text('フォロー'))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // background
                      ),
                      onPressed: () async {
                        try {
                          _Follow();
                        } catch (e) {}
                      },
                      child: Text('フォロー解除')),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text("ギフトを送る"),
                              content: TextField(
                                  onChanged: (value) {
                                    if (double.tryParse(value) != null) {
                                      giftCoin = int.parse(value);
                                    }
                                  },
                                  maxLength: 7,
                                  decoration: const InputDecoration(
                                    hintText: "送るアハコインを入力",
                                    icon: Icon(Icons.copyright_rounded),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ]),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text(
                                    "キャンセル",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    "送る",
                                    style: TextStyle(color: Colors.brown),
                                  ),
                                  onPressed: () async {
                                    final docs = await FirebaseFirestore
                                        .instance
                                        .collection('T01_Person')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .get();
                                    var data = docs.exists ? docs.data() : null;
                                    userCoin = data!["T01_AhaCoin"];

                                    if (giftCoin <= 0) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: const Text(
                                                    "0より大きい数値を入力してください"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("戻る"))
                                                ],
                                              ));
                                    } else if (userCoin < giftCoin) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content:
                                                    const Text("所持コインが足りません"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("戻る"))
                                                ],
                                              ));
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection("T02_Geinin")
                                          .doc(documentId)
                                          .get()
                                          .then((value) async {
                                        var perRef =
                                            await value.data()!["T02_GeininId"];

                                        await perRef.get().then((ref) async {
                                          flCoin = ref.data()!["T01_AhaCoin"];
                                          await perRef.update({
                                            "T01_AhaCoin": flCoin + giftCoin
                                          });
                                        });
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('T01_Person')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .update({
                                        "T01_AhaCoin": userCoin - giftCoin
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content:
                                                  Text("$giftCoinポイントをギフトしました"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("確認"))
                                              ],
                                            );
                                          });
                                    }
                                  },
                                ),
                              ]);
                        });
                    // async{try{
                    // }catch(e){}
                  },
                  child: const Text("アハコインを送る")),
              const TabBar(
                  labelColor: Colors.brown,
                  indicatorColor: Colors.brown,
                  unselectedLabelColor: Colors.black12,
                  tabs: [Tab(text: "投稿")]),
              Expanded(
                  child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                    geininFollwToukou(
                      geininFollowId: '${documentId}',
                    ),
                  ]))
            ],
          ),
        )));
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}
