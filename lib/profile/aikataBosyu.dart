import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post/uploadPost.dart';
import '../profile/geininProfile.dart';

class AikataBosyu extends StatefulWidget {
  List tag = [];
  bool isOn;
  // AikataBosyu({Key? key}) : super(key: key);
  AikataBosyu(this.tag,this.isOn){
    // print("tagの中身はなんですか");
    // print(tag);
  }
  // Home(){
  // }
  @override
  _AikataBosyuState createState() => _AikataBosyuState();
}

class _AikataBosyuState extends State<AikataBosyu> {
  // const SearchResult({Key? key}) : super(key: key);
  User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  String? documentId;
  List reTag=[];
  String reTag0="";
  String reTag1="";
  String reTag2="";
  String reTag3="";
  String reTag4="";
  TextEditingController tagController = TextEditingController();


void aikataInfoSubmit(bool isOn, List tagList) async{
  final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);
        print("ttttttttttttttttttttttttttt");
        print(gid);
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
  final ref = await FirebaseFirestore.instance.collection('T02_Geinin').doc(documentId);
  await ref.update({
    "T02_PartnerRecruit":isOn,
    "T02_Tags":tagList,
    });
}
  // 芸人が相方を募集しているかをtrueかfalseで獲得
  // void aikataTF() async{
  //   final gid = FirebaseFirestore.instance
  //       .collection("T01_Person")
  //       .doc(user!.uid);
  //   // T02_Geininの自分のdocumentIdを取得
  //   await FirebaseFirestore.instance
  //       .collection('T02_Geinin').where('T02_GeininId', isEqualTo: gid).get().then(
  //     (QuerySnapshot querySnapshot) => {
  //         querySnapshot.docs.forEach(
  //           (doc) {
  //             documentId=doc.id;
  //           },
  //         ),
  //       });
  //   final ref = await FirebaseFirestore.instance.collection('T02_Geinin').doc(documentId).get();
  //         // print(ref.data()!["T05_VideoUrl"]);
  //   isOn = await ref.data()!["T02_PartnerRecruit"];
  //   // print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  //   // print(tag[0]);
  // }

  @override
  Widget build(BuildContext context) {
    // aikataTF();
    // print("aaaaaaaaaaaaaaaaaaaaaa");
    // print(widget.tag[0].runtimeType);
    // print(tagController.text.runtimeType);
    return Scaffold(
      appBar: const Header(),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SwitchListTile(
              title: const Text('相方募集中'),
              value: widget.isOn,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    widget.isOn = value;
                  });
                }
              },
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: "${widget.tag[0]}",
                  decoration: const InputDecoration(labelText: "Tag1"),
                  // controller: tagController,
                  onChanged: (value) {
                      reTag0=value;
                  },
                  validator: (value) {
                    if(value==widget.tag[0]){
                      reTag0=widget.tag[0];
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: "${widget.tag[1]}",
                  decoration: const InputDecoration(labelText: "Tag2"),
                  // controller: tagController,
                  onChanged: (value) {
                    reTag1=value;
                  },
                  validator: (value) {
                    if(value==widget.tag[1]){
                      reTag1=widget.tag[1];
                    }
                    return null;
                  },
                )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: "${widget.tag[2]}",
                  decoration: const InputDecoration(labelText: "Tag3"),
                  // controller: tagController,
                  onChanged: (value) {
                    reTag2=value;
                  },
                  validator: (value) {
                    if(value==widget.tag[2]){
                      reTag2=widget.tag[2];
                    }
                    return null;
                  },
                )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: "${widget.tag[3]}",
                  decoration: const InputDecoration(labelText: "Tag4"),
                  // controller: tagController,
                  onChanged: (value) {
                    reTag3=value;
                  },
                  validator: (value) {
                    if(value==widget.tag[3]){
                      reTag3=widget.tag[3];
                    }
                    return null;
                  },
                )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: "${widget.tag[4]}",
                  decoration: const InputDecoration(labelText: "Tag5"),
                  // controller: tagController,
                  onChanged: (value) {
                    reTag4=value;
                  },
                  validator: (value) {
                    if(value==widget.tag[4]){
                      reTag4=widget.tag[4];
                    }
                    return null;
                  },
                )),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                      reTag=[reTag0,reTag1,reTag2,reTag3,reTag4];
                      aikataInfoSubmit(widget.isOn,reTag);
                  try {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => App()));
                } catch (e) {}
                    }
              },
              child: const Text('変更'),
            ),
            const SizedBox(
              height: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
