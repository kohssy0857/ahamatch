// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:video_player/video_player.dart';

// class sendNeta extends StatefulWidget {
//   @override
//   _sendNetaState createState() => _sendNetaState();
// }

// class _sendNetaState extends State<sendNeta> {
//   // 入力された内容を保持するコントローラ
//   File? movie = null;
//   final picker = ImagePicker();
//   Future _getmovie() async {
//     final pickedFile = await picker.getVideo(source: ImageSource.gallery);
//     print(pickedFile.toString());

//     setState(() {
//       if (pickedFile != null) {
//         movie = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print(movie);
//     return Center(
//       child: Column(
//         children: [
//           Center(
//             child: movie == null
//                 ? const Text('No image selected.')
//                 : Image.file(movie!),
//           ),
//           OutlinedButton(
//               onPressed: (() async => _getmovie()), child: const Text("動画を選択"))
//         ],
//       ),
//     );

    // Scaffold(
    //   body: Center(
    //     child: movie == null ? Text('No image selected.') : Image.file(movie),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _getImage,
    //     child: Icon(Icons.image),
    //   ),
    // );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class sendNeta extends StatefulWidget {
  @override
  _sendNetaState createState() => _sendNetaState();
}

class _sendNetaState extends State<sendNeta> {
  // 入力された内容を保持するコントローラ

  File? movie = null;
  dynamic movie_file;
  VideoPlayerController? MovieController = null;
  final picker = ImagePicker();
  Future _getmovie() async {
    var pickedFile = await picker.getVideo(source: ImageSource.gallery);
    movie_file = File(pickedFile!.path);
    print("ssssssssssss$pickedFile");
    print("ffffffffffffffffff$movie_file");

    MovieController = await VideoPlayerController.file(movie_file)
      ..initialize().then((_) async {
        print("444444444444444444444444444444${MovieController!.value}");
        setState(() {});
        print("dddddddddddddddddddddddddddddddddddddddddddddddd" +
            MovieController.toString());
        await MovieController?.play();
        print("00000000000000000000000");
      });
  }

  @override
  Widget build(BuildContext context) {
    // print(movie);
    return Center(
      child: Column(
        children: [
          Center(
              child: movie_file == null
                  ? const Text('No image selected.')
                  : AspectRatio(
                      aspectRatio: MovieController!.value.aspectRatio,
                      child: VideoPlayer(MovieController!),
                    )),
          OutlinedButton(
              onPressed: (() async => _getmovie()), child: const Text("動画を選択"))
        ],
      ),
    );

    // Scaffold(
    //   body: Center(
    //     child: movie == null ? Text('No image selected.') : Image.file(movie),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _getImage,
    //     child: Icon(Icons.image),
    //   ),
    // );
  }
}
