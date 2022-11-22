import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Footer extends StatefulWidget {
  Footer({Key? key}) : super(key: key);
  @override
  _Footer createState() => _Footer();
      
}

class _Footer extends State {
  // var user_Q = FirebaseFirestore.instance
  //     .collection('T01_Person')
  //     .where('T01_AuthId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  

  @override
  Widget build(BuildContext context) {
    User? user=FirebaseAuth.instance.currentUser;
    String? keys=FirebaseAuth.instance.currentUser!.displayName;
    
    switch (user!.displayName) {
            case "名無し @xxxxxx":
              return BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "aaa",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "",
                    ),
                  ],
                    type: BottomNavigationBarType.fixed,
              );
              break;
          default:
            return BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "2222",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "",
                ),
              ],
                type: BottomNavigationBarType.fixed,
            );
            break;
    }
    
  }
}
