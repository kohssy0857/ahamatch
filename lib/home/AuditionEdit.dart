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
import 'AuditionManagement.dart';


class AuditionEdit extends StatefulWidget {
  // AuditionManagement画面にあるmodelを取得している
  final MainModel model;
  // AuditionManagement画面にあるそれぞれのindex番号を取得している
  final int index;
  // それぞれ入力してもらったデータを表示させるための準備
  final nameController = TextEditingController();
  final itemController = TextEditingController();
  final companyController = TextEditingController();
  final imageController = TextEditingController();
  final scheduleController = TextEditingController();
  // 入力したデータを格納するそれぞれの変数
  String AuditionName = "****";
  String item = "ちょめ";
  DateTime schedule = DateTime(2020, 10, 2, 12, 10);
  String company = "ちゃめ放送";
  String? T06Image;

  AuditionEdit(this.model,this.index){
    // それぞれ入力してもらったデータを表示させるための準備
    nameController.text=model.T01_Audition[index].T05_Name;
    itemController.text=model.T01_Audition[index].T01_Item;
    companyController.text=model.T01_Audition[index].T03_Company;
    scheduleController.text=model.T01_Audition[index].T02_Schedule.toDate().toString();
    print("君はなにタイプだい？");
    print(model.T01_Audition[index].T02_Schedule);
    // 新規登録で入力されていた場合に、その値がそのまま更新されるようにしている
    // 例：編集ボタンを押した後、AuditionNameにあった名前が"****"に元に戻ってしまうため
    if(model.T01_Audition[index].T06_image!=null){
      T06Image = model.T01_Audition[index].T06_image;
    };
    if(model.T01_Audition[index].T05_Name!=null){
      AuditionName = model.T01_Audition[index].T05_Name;
    };
    if(model.T01_Audition[index].T01_Item!=null){
      item = model.T01_Audition[index].T01_Item;
    };
    if(model.T01_Audition[index].T02_Schedule!=null){
      schedule = model.T01_Audition[index].T02_Schedule.toDate();
    };
    if(model.T01_Audition[index].T03_Company!=null){
      company = model.T01_Audition[index].T03_Company;
    };
  }
  
  // const AuditionEdit({Key? key, this.T01_Audition}) : super(key: key);
  
  @override
  _AuditionEdit createState() => _AuditionEdit();
}




class _AuditionEdit extends State<AuditionEdit> {
  
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  dynamic value;
  
  // 画像の取得に必要なもの
  final picker = ImagePicker();
  File? imageFile;
  Future pickImage() async{
    final pickerFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

        if(pickerFile != null){
          imageFile = File(pickerFile.path);
        }
  }

  // 編集している関数
  void _edit(String item, DateTime schedule, String company, String AuditionName) async {
    final doc = FirebaseFirestore.instance
        .collection('T04_Event') // コレクションID
        .doc("cvabc8IsVAGQjYwPv0fR")
        // widget.indexは親のクラスのindexを読んでいる
        .collection('T01_Audition').doc(widget.model.T01_Audition[widget.index].ID); 

    // 画像取得に必要
    if(imageFile != null){
      // storageにアップロード
      final task = await FirebaseStorage.instance
        .ref("audition/${doc.id}.jpg")
        .putFile(imageFile!);
      widget.T06Image = await task.ref.getDownloadURL();
    }

    await doc.update({
      'T01_Item': item,
      'T02_Schedule': schedule,
      "T03_Company": company,
      "T04_Create": Timestamp.fromDate(DateTime.now()),
      "T05_Name": AuditionName,
      "T06_image": widget.T06Image,
    });
  }

  // 日付取得の関数
  Future _getDate(BuildContext context) async {
    final initialDate = DateTime.now();

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );

    if (newDate != null) {
      //選択した日付をTextFormFieldに設定
      widget.scheduleController.text = newDate.toString();
      // データが入力されていた場合scheduleに変更を加える
      widget.schedule = newDate;
    } else {
      return;
    }
  }



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
              width:200,
              height: 30,
              child:imageFile != null
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
                  controller: widget.nameController,
                  onChanged: (value) {
                    widget.AuditionName = value;
                  },
                  validator: (value) {
                    if (value == null||value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  controller: widget.itemController,
                  decoration: const InputDecoration(labelText: "募集要項"),
                  onChanged: (value) {
                    widget.item = value;
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
                  controller: widget.scheduleController,
                  decoration: const InputDecoration(labelText: "期限"),
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
                  controller: widget.companyController,
                  decoration: const InputDecoration(labelText: "開催社名"),
                  onChanged: (value) {
                    widget.company = value;
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
                _edit(widget.item, widget.schedule, widget.company,widget.AuditionName);
                try {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => SysHome()));
                } catch (e) {}
              },
              child: const Text('変更'),
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
