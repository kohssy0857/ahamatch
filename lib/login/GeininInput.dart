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

class GeininInput extends StatefulWidget {
  const GeininInput({Key? key}) : super(key: key);

  @override
  _GeininInput createState() => _GeininInput();
}

// enum RadioValue { TRUE, FALSE }

class _GeininInput extends State<GeininInput> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();

  void _upload(String name, List tags, String describe, String production,
      bool isOn) async {
    final id = await FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid);

    await FirebaseFirestore.instance
        .collection('T02_Geinin') // コレクションID
        .doc() // ドキュメントID
        .set({
      'T02_GeininId': id,
      'T02_UnitName': name,
      "T02_PartnerRecruit": isOn,
      "T02_Tags": tags,
      "T02_describe": describe,
      'T02_Create': Timestamp.fromDate(DateTime.now()),
      "T02_production": production,
      "T02_Follower": 0,
    });
    
  }

  String name = "";
  String describe = "";
  String production = "";
  List<String> tags = [];
  bool isOn = false;
  String tag1 = "";
  String tag2 = "";
  String tag3 = "";
  String tag4 = "";
  String tag5 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(

          child:Form(
            key: _formKey,

            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "ユニット名"),
                  onChanged: (value) {
                    name = value;
                  },
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
                  decoration: const InputDecoration(labelText: "所属事務所"),
                  onChanged: (value) {
                    production = value;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "紹介文"),
                  onChanged: (value) {
                    describe = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "必須です";
                    }
                    return null;
                  },
                )),
            SwitchListTile(
              title: const Text('相方募集中'),
              value: isOn,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    isOn = value;
                  });
                }
              },
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "タグ1"),
                  onChanged: (value) {
                    tag1 = value;
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
                  decoration: const InputDecoration(labelText: "タグ2"),
                  onChanged: (value) {
                    tag2 = value;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "タグ3"),
                  onChanged: (value) {
                    tag3 = value;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "タグ4"),
                  onChanged: (value) {
                    tag4 = value;
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "タグ5"),
                  onChanged: (value) {
                    tag5 = value;
                  },
                )),
            ElevatedButton(
              onPressed: () async {
                if(_formKey.currentState!.validate()){
                  tags.addAll([tag1, tag2, tag3, tag4, tag5]);
                  _upload(name, tags, describe, production, isOn);
                  try {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => App()));
                  } catch (e) {}
                }
              },
              child: const Text('登録'),
            ),
          ],
        ))),
      ),
    );
  }
}

