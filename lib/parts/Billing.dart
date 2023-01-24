import 'package:ahamatch/home/home.dart';
import 'package:ahamatch/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parts/header.dart';

class Billing extends StatefulWidget {
  Billing({Key? key}) : super(key: key);
  @override
  _BillingState createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Header(),
        body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "アハコイン購入",
                  textAlign: TextAlign.center,
                ),
                billingContainer(120, 100),
                billingContainer(120, 100),
                billingContainer(120, 100),
                billingContainer(120, 100),
                billingContainer(120, 100)
              ]),
        ));
  }

  Container billingContainer(int price, int amount) {
    return Container(
      width: 400,
      height: 50,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("$amountアハコイン"),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  )),
              child: GestureDetector(
                onTap: () {
                  BillingDialog(price, amount);
                },
                child: Text("$price円"),
              ))
        ],
      ),
    );
  }

  BillingDialog(int price, int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dialog!"),
        content: const Text("Text of Something"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "キャンセル",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
              onPressed: () async {
                final docs = await FirebaseFirestore.instance
                    .collection('T01_Person')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get();
                var data = docs.exists ? docs.data() : null;
                var coin = data!["T01_AhaCoin"] + amount;
                await FirebaseFirestore.instance
                    .collection('T01_Person')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({"T01_AhaCoin": coin});
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("完了"),
                          content: Text("$amountコインが追加されました"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => App()));
                                },
                                child: Text("戻る"))
                          ],
                        ));
              },
              child: const Text("購入"))
        ],
      ),
    );
  }
}
