import 'dart:ffi';

import 'package:ahamatch/home/AuditionInput.dart';
import 'package:ahamatch/profile/mylist.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../parts/footer.dart';

import '../parts/header.dart';
import 'mylist.dart';


class owaraizukiProfile extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
      Stream<Image> getAvatarUrlForProfile() async* {
          final ref =  FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
      // no need of the file extension, the name will do fine.
          var url = await ref.getDownloadURL();
          
          
          yield Image.network(
          url,
          width: 300,
          height: 300,);
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: Header(),
              body: Column( //RowとStackでも同じ
                children: [
                  Text('プロフィール名：${user!.displayName}====2'),
                  // Text(img.toString()),
                  StreamBuilder(stream: getAvatarUrlForProfile(),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Text("no photo");
                    }else if (snapshot.hasData){
                      Image photo = snapshot.data!;
                      return  photo;
                    } else {
                      return const Text("not photo");
                    }
                    },),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => mylist()));
                      } catch (e) {}
                    },
                    child: const Text('マイリスト'),
                  ), 
                ],
                
          ), 
          // body: Center(
          //   child:StreamBuilder(img?, builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  },)
          // ),
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.add),
          //   onPressed: () async {
          //     await FirebaseAuth.instance.signOut();
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => UserLogin()));
          //     /* --- 省略 --- */
          //   },
          // ),
          // bottomNavigationBar: Footer(),
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
