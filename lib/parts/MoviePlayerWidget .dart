import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'FullscreenVideo.dart';

/*
 * 動画ウィジェット
 */
class MoviePlayerWidget extends StatefulWidget {
  String movieURL; // 動画URL
  String movieId; // 動画URL
  MoviePlayerWidget(this.movieURL, this.movieId) : super();

  @override
  _MoviePlayerWidgetState createState() => _MoviePlayerWidgetState();
}

/*
 * ステート
 */

class _MoviePlayerWidgetState extends State<MoviePlayerWidget> {
  // コントローラー
  late VideoPlayerController _controller;

  @override
  void initState() {
    // 動画プレーヤーの初期化
    _controller = VideoPlayerController.network(
      widget.movieURL,
    )..initialize().then((_) {
        setState(() {});
        // _controller.play();
      });

    super.initState();
  }

  @override
  // void buildVideo(size) {
  //   // print("フルスクリーンボタン押下");
  //   // print(size);
  //   // print(size.height);
  //   FittedBox(
  //       fit: BoxFit.fill,
  //       child: AspectRatio(
  //       aspectRatio: _controller.value.aspectRatio,
  //       // 動画を表示
  //       child: VideoPlayer(_controller),
  //     ),
  //     );
  // }

  Widget build(BuildContext context) {
    if (_controller == null) return Container();
    final size = _controller.value.size;
    final movieWidth = size.width;
    final movieHeight = size.height;
    if (_controller.value.isInitialized) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // 動画を表示
              child: VideoPlayer(_controller),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullscreenVideo(
                                    widget.movieId, movieHeight, movieWidth)))
                        .then((value) {
                      // 再描画
                      setState(() {});
                    });
                    ;
                  },
                  icon: Icon(Icons.fullscreen),
                ),
              ],
            ),
          ],
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
}
