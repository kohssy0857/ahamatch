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

class _GeininInput extends State<GeininInput> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();

  void _upload(int type, String name, String id) async {
    await FirebaseFirestore.instance
        .collection('T01_Person') // コレクションID
        .doc(user!.uid) // ドキュメントID
        .set({
      // 'T01_AhaPoint': 0,
      // 'T01_Kind': type,
      // "T01_Subscribe": false,
      // "T01_UserId": userid,
      // "T01_DisplayName": name,
      // 'T01_Create': Timestamp.fromDate(DateTime.now())
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
            ElevatedButton(
              onPressed: () async {
                try {} catch (e) {}
              },
              child: const Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
