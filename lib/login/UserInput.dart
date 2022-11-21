import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class UserInput extends StatefulWidget {
  const UserInput({Key? key}) : super(key: key);

  @override
  _UserInput createState() => _UserInput();
}

enum Kind { admin, geinin, owaraizuki }

var _radVal = Kind.owaraizuki;
// void _onChanged(Kind value) {
//   setState(() {
//     _radVal = value;
//   });
// }

class _UserInput extends State<UserInput> {
  final Kind _first_button = Kind.admin;
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  void _upload() async {
    // imagePickerで画像を選択する
    // upload

    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File file = File(pickerFile!.path);
    await FirebaseStorage.instance
        .ref("profile/${user!.uid}.jpg")
        .putFile(file);
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
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "ID"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "表示名"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            // Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: TextFormField(
            //       autofocus: true,
            //       decoration: const InputDecoration(labelText: "表示名"),
            //       validator: (value) {
            //         if (value!.isEmpty) {
            //           return "必須です";
            //         }
            //         return null;
            //       },
            //     )),
            // FloatingActionButton(
            //   onPressed: _upload, //カメラから画像を取得
            //   tooltip: 'Pick Image From Camera',
            //   child: const Icon(Icons.add_a_photo),
            // ),
            const SizedBox(
              height: 40.0,
            ),
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  child: Text('システム管理者'),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text('芸人'),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text('お笑い好き'),
                  value: 2,
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
              onPressed: () {
                try {
                  _upload;
                  switch (isSelectedItem) {
                    case 0:
                      user!.updateDisplayName(name + " -" + id);
                      break;
                    case 1:
                      user!.updateDisplayName(name + " #" + id);
                      break;
                    case 2:
                      user!.updateDisplayName(name + " @" + id);
                      break;
                  }
                  user!.updatePhotoURL("profile/${user!.uid}.jpg");
                } catch (e) {
                  const UserInput();
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
