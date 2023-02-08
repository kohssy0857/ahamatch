import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
// 以下をインポート
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart'; // use rootBundle
import 'package:audioplayers/audioplayers.dart';
import 'convention_fulscr.dart';

/*
 * 動画ウィジェット
 */
class ConFullMoviePlayer extends StatefulWidget {
  String movieURL; // 動画URL
  String movieId;
  List events;
  int index;

  ConFullMoviePlayer(this.movieURL, this.movieId, this.events, this.index)
      : super();

  @override
  _FullMoviePlayerWidgetState createState() => _FullMoviePlayerWidgetState();
}

/*
 * ステート
 */

class _FullMoviePlayerWidgetState extends State<ConFullMoviePlayer> {
  // ~~~~~~~~~~
  List list = [];
  List id = [];
  final user = FirebaseAuth.instance.currentUser;
//   int _counter = 0;
//  final _audio = AudioCache();
  Soundpool _pool = Soundpool(streamType: StreamType.notification);
  Stream<QuerySnapshot>? chats;
  String elementId = "";
  bool laughTF = false;
  

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
  Future _takevotepoint() async {
    final doc = await FirebaseFirestore.instance
        .collection("T04_Event")
        .doc("cvabc8IsVAGQjYwPv0fR")
        .collection("T02_Convention")
        .doc(widget.events[widget.index].docid)
        .collection("Vote_Name");
    doc
        .where("PersonId", isEqualTo: user!.uid)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        // if (doc["T05_Type"] == 1) {
        list.add(doc["PersonId"]);
      });
    });

    await FirebaseFirestore.instance
        .collection("T07_Convention")
        .where("T07_VideoUrl", isEqualTo: widget.movieURL)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        id.add(doc.id);
      });
    });
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
      _takevotepoint();
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _controller.value.size.height / 2.3,
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
                    // if (smileList != null) {
                    //   return Text(
                    //     _videoDuration(value.position),
                    //     style: const TextStyle(
                    //       color: Colors.black,
                    //       fontSize: 20,
                    //     ),
                    //   );
                    // } else {
                    //   // print("スマイルリストはありませんよ");
                    return Text(
                      _videoDuration(value.position),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    );
                    // }
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                ),
              ],
            ),
            // Positioned(
            //   left: 100,
            //   bottom: 45,
            //   child: FloatingActionButton(
            //     child: const Icon(Icons.how_to_vote),
            //     onPressed: () async {
            //       _vote();
            //     },
            //   )
            // ),
          ]
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.how_to_vote),
          onPressed: () async {
            _vote();
          },
        ),
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

  _vote() async {
    if (list.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("一度投票すると再度投票することはできません"),
          content: const Text("このネタに投票しますか？"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                _countVote();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('すでに投票しています'),
        ),
      );
    }
  }

  _countVote() async {
    final doc = await FirebaseFirestore.instance
        .collection("T04_Event")
        .doc("cvabc8IsVAGQjYwPv0fR")
        .collection("T02_Convention")
        .doc(widget.events[widget.index].docid)
        .collection("Vote_Name");
    final ref = doc.doc();

    await ref.set({
      "PersonId": FirebaseAuth.instance.currentUser!.uid,
    });

    FirebaseFirestore.instance
        .collection("T07_Convention")
        .doc(id[0])
        .update({"T07_votes": FieldValue.increment(1)});
    print("投票数＋1");
  }
}
