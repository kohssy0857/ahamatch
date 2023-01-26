import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../post/uploadPost.dart";
import '../parts/footer.dart';
import '../parts/header.dart';
import 'convention_list.dart';
import 'events_list.dart';
import '../functions.dart';

class ConOverview extends StatefulWidget {
  final List<Convention> model;
  final int index;
  const ConOverview({
    required this.model,
    required this.index,
  }) : super();

  @override
  _ConOverview createState() => _ConOverview();
}

class _ConOverview extends State<ConOverview> {
  int i = 0;
  List list = [];
  List unitname = [];
  List a = [];

  Stream<QuerySnapshot>? chats;

  getChats() async {
    for (i = 0; i < widget.model.length; i++) {
      await FirebaseFirestore.instance
          .collection('T07_Convention')
          .where("T07_Convention", isEqualTo: widget.model[widget.index].docid)
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((element) {
          list.add(element["T07_Geinin"]);
        });
      });
    }
    print(list);
    // for (i = 0; i < list.length; i++) {
     return FirebaseFirestore.instance
      .collection("T02_Geinin")
      // .where("T02_Geinin", isEqualTo: list[i])
      .where("T02_Geinin", whereIn: list)
      .snapshots();
      // .get()
      // .then((QuerySnapshot snapshot) {
      // snapshot.docs.forEach((doc) {
      //   unitname.add(doc["T02_UnitName"]);
      // });
      // });
    // }
    // return unitname;
  }

  getChatandAdmin() {
    getChats().then((val) {
      setState(() {
        print(val);
        chats = val;
      });
    });
  }

  contestant() {
    return 
    StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? 
              ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Text(snapshot.data.docs[index]),
                          ),
                        )
                      ],
                    );
                  },
                )
              : Container();
        });
  }

  @override
  void initState() {
    getChatandAdmin();

    super.initState();
  }

  @override
  // _ConOverview createState() => _ConOverview();
  Widget build(BuildContext context) {
    DateTime schedule = widget.model[widget.index].schedule.toDate();
    return Scaffold(
      body: SingleChildScrollView(
        // ユーザー情報を表示
        child: Column(children: [
          Container(
            // height: 50,
            child: Text('大会名：${widget.model[widget.index].name}'),
          ),
          Divider(),
          Container(
            height: 100,
            child: Text('大会概要\n' +
                '条件：${widget.model[widget.index].condition}\n' +
                '期限：' +
                schedule.toString() +
                '\n' +
                '賞品：${widget.model[widget.index].prize}'),
          ),
          const Divider(),
          Container(
            child: Text('出場者一覧'),
          ),
          contestant(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white, // background
              onPrimary: Colors.black, // foreground
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text('戻る'),
          ),
        ]),
      ),
    );
  }
}
