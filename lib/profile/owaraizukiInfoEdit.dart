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



class owaraizukiInfoEdit extends StatefulWidget {
  String url;
  String userName;
  // AikataBosyu({Key? key}) : super(key: key);
  owaraizukiInfoEdit(this.url,this.userName){
  }
  // Home(){
  // }
  @override
  _owaraizukiInfoEditState createState() => _owaraizukiInfoEditState();
}

class _owaraizukiInfoEditState extends State<owaraizukiInfoEdit> {
  // const SearchResult({Key? key}) : super(key: key);
  User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  String userName = "";
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
void _edit(String userName) async {
      final userGid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);
      final gid = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);

      // 画像取得に必要
      if (imageFile != null) {
        // storageにアップロード
        await FirebaseStorage.instance
            .ref("profile/${user!.uid}.jpg")
            .putFile(imageFile!);
      }
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
            
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                      // reTag=[reTag0,reTag1,reTag2,reTag3,reTag4];
                      // aikataInfoSubmit(widget.isOn,reTag);
                      _edit(userName);
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
