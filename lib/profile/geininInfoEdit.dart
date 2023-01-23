import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post/uploadPost.dart';
import '../profile/geininProfile.dart';
import 'dart:io';



class geininInfoEdit extends StatefulWidget {
  String shoukai;
  String url;
  String userName;
  String unitName;
  // AikataBosyu({Key? key}) : super(key: key);
  geininInfoEdit(this.shoukai,this.url,this.userName,this.unitName){
  }
  // Home(){
  // }
  @override
  _geininInfoEditState createState() => _geininInfoEditState();
}

class _geininInfoEditState extends State<geininInfoEdit> {
  // const SearchResult({Key? key}) : super(key: key);
  User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  String? documentId;
  String newshoukai="";
  String userName = "";
  String unitName= "";
  TextEditingController Controller = TextEditingController();

  // 画像の取得に必要なもの
  final picker = ImagePicker();
  String T01Image = "";
  String? url;

  File? imageFile;
  Future pickImage() async{
    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
        setState(() {
      if (pickerFile!= null) {
        imageFile = File(pickerFile.path);
        T01Image = pickerFile.path;
      }
    });
  }

  // プロフィール画像の取得
  Future pickProfile()async{
    final ref =  FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
      // no need of the file extension, the name will do fine.
    url = await ref.getDownloadURL();
  }


// 芸人の情報を編集する関数
void _edit(String shoukai,String userName,String unitName) async {
      final userGid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);
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
      // 画像取得に必要
      if (imageFile != null) {
        // storageにアップロード
        await FirebaseStorage.instance
            .ref("profile/${user!.uid}.jpg")
            .putFile(imageFile!);
      }
    final ref = await FirebaseFirestore.instance.collection('T02_Geinin').doc(documentId);
    await ref.update({
      "T02_describe":shoukai,
      "T02_UnitName":unitName,
      });
    await userGid.update({
      "T01_DisplayName":userName,
      });
  }

  @override
  Widget build(BuildContext context) {
    pickProfile();
    return Scaffold(
      appBar: const Header(),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
            width: 500,
            height: 500,
            child: imageFile == null
                  ? Image.network(
                      widget.url,
                      width: 300,
                      height: 300,)
                  : Image.file(
                    imageFile!,
                    )
          ),
          Container(
              alignment: Alignment.center,
              child: Container(
                width: 300,
                height: 100,
                child:SizedBox(
              width:200,
              height: 30,
              child:ElevatedButton(
                  onPressed: () async {
                    await pickImage();
                  },
                  child: Text('プロフィール画像を選択'),
                ),
            ),
              ),
              
              ),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: widget.userName,
                  decoration: const InputDecoration(labelText: "ユーザ名"),
                  // controller: tagController,
                  onChanged: (value) {
                      userName=value;
                  },
                  validator: (value) {
                    if(value==widget.userName){
                      userName=widget.userName;
                    }else if (value == null || value.isEmpty) {
                      return "必須です";
                    } 
                  },
                )),
                Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: widget.unitName,
                  decoration: const InputDecoration(labelText: "ユニット名"),
                  // controller: tagController,
                  onChanged: (value) {
                      unitName=value;
                  },
                  validator: (value) {
                    if(value==widget.unitName){
                      unitName=widget.unitName;
                    }else if (value == null || value.isEmpty) {
                      return "必須です";
                    } 
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  initialValue: widget.shoukai,
                  decoration: const InputDecoration(labelText: "プロフィール文"),
                  // controller: tagController,
                  onChanged: (value) {
                      newshoukai=value;
                  },
                  validator: (value) {
                    if(value==widget.shoukai){
                      newshoukai=widget.shoukai;
                    }else if (value == null || value.isEmpty) {
                      return "必須です";
                    } 
                  },
                )),
            
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                      // reTag=[reTag0,reTag1,reTag2,reTag3,reTag4];
                      // aikataInfoSubmit(widget.isOn,reTag);
                      _edit(newshoukai,userName,unitName);
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
