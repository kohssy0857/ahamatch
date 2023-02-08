// ignore_for_file: library_private_types_in_public_api

import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GeininInput.dart';
import '../login/login.dart';
import 'loginFollow.dart';
import '../home/SysHome.dart';

class UserInput extends StatefulWidget {
  const UserInput({Key? key}) : super(key: key);

  @override
  _UserInput createState() => _UserInput();
}

enum Kind { admin, geinin, owaraizuki }

class _UserInput extends State<UserInput> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();

  Future _upload(int type, String name, String id) async {
    String userid = "";
    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File file = File(pickerFile!.path);
    user!.updatePhotoURL("profile/${user!.uid}.jpg");
    await FirebaseStorage.instance
        .ref("profile/${user!.uid}.jpg")
        .putFile(file);

    switch (isSelectedItem) {
      case 0:
        userid = "-$id";
        await user!.updateDisplayName("$name-$id");
        break;
      case 1:
        userid = "#$id";
        await user!.updateDisplayName("$name#$id");
        break;
      case 2:
        userid = "@$id";
        await user!.updateDisplayName("$name@$id");
        break;
    }
    await FirebaseFirestore.instance
        .collection('T01_Person') // コレクションID
        .doc(user!.uid) // ドキュメントID
        .set({
      'T01_AhaCoin': 0,
      'T01_Kind': type,
      "T01_Subscribe": false,
      "T01_UserId": userid,
      "T01_DisplayName": name,
      'T01_Create': Timestamp.fromDate(DateTime.now())
    });
  }

  String name = "名無し";
  String id = "xxxxxx";

  int? isSelectedItem = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "ID"),
                  onChanged: (value) {
                    id = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    } else if (value.contains("@") || value.contains("#")|| value.contains("-")) {
                      return "「@、＃、-」は使えません";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "表示名"),
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    } else if (value.contains("@") ||
                        value.contains("#") ||
                        value.contains("-")) {
                      return "「@、＃、-」は使えません";
                    }
                    return null;
                  },
                )),
            const SizedBox(
              height: 40.0,
            ),
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('システム管理者'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('芸人'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('お笑い好き'),
                ),
              ],
              onChanged: (int? value) {
                setState(() {
                  isSelectedItem = value;
                });
              },
              value: isSelectedItem,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _upload(isSelectedItem!, name, id);
                  try {
                    if (isSelectedItem == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => loginFollowMane()));
                    } else if (isSelectedItem == 0) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SysHome()));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => loginFollowMane()));
                    }
                  } catch (e) {}
                }
              },
              child: const Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
