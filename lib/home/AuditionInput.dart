import 'dart:developer';

import 'package:ahamatch/home/SysHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/footer.dart';
import '../parts/header.dart';
import 'AuditionManagement.dart';
import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuditionInput extends StatefulWidget {
  const AuditionInput({Key? key}) : super(key: key);

  @override
  _AuditionInput createState() => _AuditionInput();
}

class _AuditionInput extends State<AuditionInput> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  // 画像アップロードに必要な物
  final picker = ImagePicker();
  File? imageFile;
  Future pickImage() async {
    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickerFile != null) {
      imageFile = File(pickerFile.path);
    }
  }

  void _upload(String item, DateTime schedule, String company,
      String AuditionName) async {
    String? T06_image;

    final doc = FirebaseFirestore.instance
        .collection('T04_Event') // コレクションID
        .doc("cvabc8IsVAGQjYwPv0fR")
        .collection('T01_Audition')
        .doc();

    if (imageFile != null) {
      // storageにアップロード
      final task = await FirebaseStorage.instance
          .ref("audition/${doc.id}.jpg")
          .putFile(imageFile!);
      T06_image = await task.ref.getDownloadURL();
    }

    await doc.set({
      'T01_Item': item,
      'T02_Schedule': schedule,
      "T03_Company": company,
      "T04_Create": Timestamp.fromDate(DateTime.now()),
      "T05_Name": AuditionName,
      "T06_image": T06_image,
      "T07_DocumentId": doc.id,
    });
    print("登録できました");
  }

  Future _getDate(BuildContext context) async {
    final initialDate = DateTime.now();

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );

    if (newDate != null) {
      print(newDate.runtimeType);
      //選択した日付をTextFormFieldに設定
      textEditingController.text = newDate.toString();
      schedule = newDate;
    } else {
      return;
    }
  }

  String item = "初期募集要項";
  String AuditionName = "初期オーディションネーム";
  DateTime schedule = DateTime(2020, 10, 2, 12, 10);
  String company = "初期会社名";
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('オーディション情報入力'),
      ),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              height: 30,
              child: imageFile != null
                  ? Image.file(imageFile!)
                  : ElevatedButton(
                      onPressed: () async {
                        await pickImage();
                      },
                      child: Text('オーディション画像選択'),
                    ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "オーディション名"),
                  onChanged: (value) {
                    print("valueは何だい？？？？");
                    print(value);
                    AuditionName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "募集要項"),
                  onChanged: (value) {
                    item = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "期限"),
                  onChanged: (value) => {},
                  controller: textEditingController,
                  onTap: () {
                    _getDate(context);
                  },
                  validator: (context) {
                    if (context!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "開催社名"),
                  onChanged: (value) {
                    company = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            const SizedBox(
              height: 40.0,
            ),
            ElevatedButton(
              onPressed: () async {
                if(_formKey.currentState!.validate()){
                  _upload(item, schedule, company, AuditionName);
                  try {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SysHome()));
                  } catch (e) {}
                }
              },
              child: const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}

Stream<QuerySnapshot> getStreamSnapshots(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .where("title", isEqualTo: "test")
      .orderBy('createdAt', descending: true)
      .snapshots();
}
