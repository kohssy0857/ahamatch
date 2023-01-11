import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'FullscreenVideo.dart';

/*
 * 動画ウィジェット
 */
class FullMoviePlayerWidget extends StatefulWidget {

  String movieURL; // 動画URL
  FullMoviePlayerWidget(this.movieURL,) : super();

  @override
  _FullMoviePlayerWidgetState createState() => _FullMoviePlayerWidgetState();
}


/*
 * ステート
 */

class _FullMoviePlayerWidgetState extends State<FullMoviePlayerWidget> {

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
    final width = size.width;
    final height = size.height;
    if (_controller.value.isInitialized) {
      return Scaffold(
  body: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // FittedBox(
      //   fit: BoxFit.cover,
      //   child: AspectRatio(
      //   aspectRatio: _controller.value.aspectRatio,
      //   // 動画を表示
      //   child: SizedBox(
      //     width: width,
      //     height: height,
      //     child: VideoPlayer(_controller),
      //   ),
      // ),
      // ),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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