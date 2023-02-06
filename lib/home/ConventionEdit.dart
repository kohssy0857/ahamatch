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
import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'ConventionManagement.dart';

class ConventionEdit extends StatefulWidget {
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
  String ConventionName = "****";
  String conditions = "ちょめ";
  DateTime schedule = DateTime(2020, 10, 2, 12, 10);
  String prize = "ちゃめ放送";
  String? T06Image;

  ConventionEdit(this.model,this.index){
    // それぞれ入力してもらったデータを表示させるための準備
    nameController.text=model.T02_Convention[index].T05_Name;
    itemController.text=model.T02_Convention[index].T01_Conditions;
    companyController.text=model.T02_Convention[index].T03_Prize;
    scheduleController.text=model.T02_Convention[index].T02_Schedule.toDate().toString();
    print("君はなにタイプだい？");
    print(model.T02_Convention[index].T02_Schedule);
    // 新規登録で入力されていた場合に、その値がそのまま更新されるようにしている
    // 例：編集ボタンを押した後、AuditionNameにあった名前が"****"に元に戻ってしまうため
    if(model.T02_Convention[index].T06_image!=null){
      T06Image = model.T02_Convention[index].T06_image;
    };
    if(model.T02_Convention[index].T05_Name!=null){
      ConventionName = model.T02_Convention[index].T05_Name;
    };
    if(model.T02_Convention[index].T01_Conditions!=null){
      conditions = model.T02_Convention[index].T01_Conditions;
    };
    if(model.T02_Convention[index].T02_Schedule!=null){
      schedule = model.T02_Convention[index].T02_Schedule.toDate();
    };
    if(model.T02_Convention[index].T03_Prize!=null){
      prize = model.T02_Convention[index].T03_Prize;
    };
  }
  
  // const AuditionEdit({Key? key, this.T01_Audition}) : super(key: key);
  
  @override
  _ConventionEdit createState() => _ConventionEdit();
}




class _ConventionEdit extends State<ConventionEdit> {
  
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
  void _edit(String conditions, DateTime schedule, String prize, String ConventionName) async {
    final doc = FirebaseFirestore.instance
        .collection('T04_Event') // コレクションID
        .doc("cvabc8IsVAGQjYwPv0fR")
        // widget.indexは親のクラスのindexを読んでいる
        .collection('T02_Convention').doc(widget.model.T02_Convention[widget.index].ID); 

    // 画像取得に必要
    if(imageFile != null){
      // storageにアップロード
      final task = await FirebaseStorage.instance
        .ref("convention/${doc.id}.jpg")
        .putFile(imageFile!);
      widget.T06Image = await task.ref.getDownloadURL();
    }

    await doc.update({
      'T01_Conditions': conditions,
      'T02_Schedule': schedule,
      "T03_Prize": prize,
      "T04_Create": Timestamp.fromDate(DateTime.now()),
      "T05_Name": ConventionName,
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
            title: Text('大会情報入力'),
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
                  child: Text('大会画像選択'),
                ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "大会名"),
                  controller: widget.nameController,
                  onChanged: (value) {
                    widget.ConventionName = value;
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
                    widget.conditions = value;
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
                    widget.prize = value;
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
                _edit(widget.conditions, widget.schedule, widget.prize,widget.ConventionName);
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
