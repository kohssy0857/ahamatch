import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:video_player/video_player.dart';
import 'FullscreenVideo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
// 以下をインポート
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart'; // use rootBundle
import 'package:audioplayers/audioplayers.dart';
import 'dart:collection';

/*
 * 動画ウィジェット
 */
class FullMoviePlayerWidget extends StatefulWidget {
  String movieURL; // 動画URL
  String movieId;
  FullMoviePlayerWidget(this.movieURL, this.movieId) : super();

  @override
  _FullMoviePlayerWidgetState createState() => _FullMoviePlayerWidgetState();
}

/*
 * ステート
 */

class _FullMoviePlayerWidgetState extends State<FullMoviePlayerWidget> {
  // ~~~~~~~~~~
  List smileList = [];
  final user = FirebaseAuth.instance.currentUser;
//   int _counter = 0;
//  final _audio = AudioCache();
  Soundpool _pool = Soundpool(streamType: StreamType.notification);
  Stream<QuerySnapshot>? chats;
  String elementId = "";
  bool laughTF = false;
  int typeTF = 0;

// コメントを獲得
  getChats() async {
    return FirebaseFirestore.instance
        .collection('T05_Toukou')
        .doc(widget.movieId)
        .collection('Comment')
        .orderBy('Create', descending: true)
        .snapshots();
  }

  getChatandAdmin() {
    getChats().then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Text("${snapshot.data.docs[index]['User']}：" +
                        "${snapshot.data.docs[index]['Comment']}"),
                    decoration: BoxDecoration(
                      border: const Border(
                        bottom: const BorderSide(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }

  void _incrementCounter() async {
    int soundId = await rootBundle
        .load("assets/se/sample-3s.mp3")
        .then((ByteData soundData) {
      return _pool.load(soundData);
    });
    int streamId = await _pool.play(soundId);
  }
  // ~~~~~~~~~~

  // コントローラー
  late VideoPlayerController _controller;
  //
  VoidCallback _listener = () => {};
  __ProgressTextState() {
    _listener = () {
      // 検知したタイミングで再描画する
      setState(() {});
    };
  }

  // 読み込み時にアハポイントを取得する
  Future _takeAhapoint() async {
    final smileCheck = FirebaseFirestore.instance
        .collection("T05_Toukou")
        .doc(widget.movieId)
        .collection("AhaPoint");
    smileCheck.get().then((docSnapshot) async => {
          if (docSnapshot.docs.isNotEmpty)
            {
              // print("あるよ"),
              await FirebaseFirestore.instance
                  .collection('T05_Toukou')
                  .doc(widget.movieId)
                  .collection("AhaPoint")
                  .get()
                  .then((QuerySnapshot snapshot) {
                snapshot.docs.forEach((doc) {
                  if (smileList.contains(doc["Point"]) == false) {
                    smileList.add(doc["Point"]);
                    smileList.sort();
                  }
                });
              }),
              // print(smileList),
            }
          else
            {
              // print("ないよ")
            }
        });
    final ref5 = await FirebaseFirestore.instance
        .collection("T05_Toukou")
        .doc(widget.movieId)
        .get();
    // print("typeはなんだえ" + "${ref5.data()!["T05_Type"]}");
    typeTF = ref5.data()!["T05_Type"];
  }

// 視聴回数を＋１
  void addShityoukaisu() {
    FirebaseFirestore.instance
        .collection('T05_Toukou')
        .doc(widget.movieId)
        .update({"T05_ShityouKaisu": FieldValue.increment(1.0)});
  }

// 笑い声を再生
  void _laughVoice(Duration duration, List smileList, Duration time) async {
    for (int i = 0; i < smileList.length; i++) {
      // print("現在の再生時間");
      // print(duration);
      if (time.inSeconds == duration.inSeconds)
        break;
      if (duration.inSeconds== smileList[i]) {
        // print("笑い動画が再生し続ける");
        // print(duration.inSeconds);
        if (laughTF) {
          int soundId = await rootBundle
              .load("assets/se/sample-3s.mp3")
              .then((ByteData soundData) {
            return _pool.load(soundData);
          });
          int streamId = await _pool.play(soundId);
        }
      } else {
        // print("No~~~~~~~~~~~~~~~~");
      }
    }
  }

// マイリストに追加
  void addMylist(String videoUrl, String movieId) async {
    final mylistcheck = FirebaseFirestore.instance
        .collection("T01_Person")
        .doc(user!.uid)
        .collection("mylist");
    mylistcheck.get().then((docSnapshot) async => {
          // 存在しない場合、フォローを行う
          await FirebaseFirestore.instance
              .collection('T01_Person')
              .doc(user!.uid)
              .collection("mylist")
              .doc()
              .set({
            'videoUrl': videoUrl,
            'movieId': movieId,
            "Create": Timestamp.fromDate(DateTime.now()),
          }),
          print("登録できました"),
        });
  }

// アハポイント登録関数
  void smilePoint(Duration duration) async {
    final ref = await FirebaseFirestore.instance
        .collection('T05_Toukou')
        .doc(widget.movieId)
        .collection("AhaPoint")
        .doc();
    await ref.set({
      'Point': duration.inSeconds.remainder(3600),
    });
    print("登録できました");
  }

  String _videoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(":");
  }

  @override
  void initState() {
    getChatandAdmin();
    addShityoukaisu();
    _takeAhapoint();
    // 動画プレーヤーの初期化
    _controller = VideoPlayerController.network(
      widget.movieURL,
    )..initialize().then((_) {
        setState(() {});
        // _controller.play();
      });

    super.initState();
    //
    _controller.addListener(_listener);
  }

  @override
  void deactivate() {
    _controller.removeListener(_listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return Container();
    if (_controller.value.isInitialized) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _controller.value.size.height / 2,
              width: _controller.value.size.width / 2,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                // 動画を表示
                child: VideoPlayer(_controller),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, child) {
                    if (smileList != null) {
                      // print("スマイルリストはありますよ");
                      // print(value.position.inSeconds.remainder(3600));
                      if (laughTF == true) {
                        _laughVoice(value.position, smileList,
                            _controller.value.duration);
                      }
                      return Text(
                        _videoDuration(value.position),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      );
                    } else {
                      // print("スマイルリストはありませんよ");
                      return Text(
                        _videoDuration(value.position),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      );
                    }
                  },
                ),
                Expanded(
                  child: SizedBox(
                    height: 20,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                IconButton(
                  onPressed: () {
                    // 動画を最初から再生
                    _controller
                        .seekTo(Duration.zero)
                        .then((_) => _controller.play());
                  },
                  icon: Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () {
                    // 動画を再生
                    _controller.play();
                  },
                  icon: Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {
                    // 動画を一時停止
                    _controller.pause();
                  },
                  icon: Icon(Icons.pause),
                ),
              ],
            ),
            // |||||||||||||||||||
            Row(
              children: [
                if (typeTF == 1)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('笑い声をON'),
                          ),
                        );
                        laughTF = true;
                      } catch (e) {}
                    },
                    child: const Text('笑い声再生'),
                  ),
                if (typeTF == 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                    ),
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('笑い声をOFF'),
                          ),
                        );
                        laughTF = false;
                      } catch (e) {}
                    },
                    child: const Text('笑い声停止'),
                  ),
                SizedBox(width: 150),
                if (typeTF == 1)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('アハポイントを追加しました'),
                          ),
                        );
                        smilePoint(_controller.value.position);
                      } catch (e) {}
                    },
                    child: const Text('アハポイント'),
                  ),
                if (typeTF == 1)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('マイリストに追加しました'),
                          ),
                        );
                        addMylist(widget.movieURL, widget.movieId);
                      } catch (e) {}
                    },
                    child: const Text('マイリスト'),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      _myDialog();
                    } catch (e) {}
                  },
                  child: const Text('コメント'),
                )
              ],
            )
            // chatMessages(),

            // ||||||||||||||||||||
          ],
        ),
        //       floatingActionButton: FloatingActionButton(
        //    onPressed: _incrementCounter,
        //    tooltip: 'Increment',
        //    child: Icon(Icons.add),
        //  ),
      );
    } else {
      /*
       * インジケータを表示
       */
      return Container(
        height: 150.0,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _myDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('コメント'),
        content: Container(
          width: 500,
          height: 800,
          child: chatMessages(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
