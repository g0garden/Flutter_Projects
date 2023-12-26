import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  const CustomVideoPlayer({required this.video, super.key});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();

    initVideoController();
  }

  initVideoController() async {
    videoController = VideoPlayerController.file(
        //XFile -> file
        File(widget.video.path));

    await videoController!.initialize();

    //videocontroller를 실행하고 나서 위젯 한 번 빌드해줘야되니까
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: Stack(children: [
          VideoPlayer(videoController!),
          _Controls(
              onPlayPressed: onPlayPressed,
              onReversePressed: onReversePressed,
              onForwardPressed: onForwardPressed,
              isPlaying: videoController!.value.isPlaying),
          Positioned(
            right: 0,
            child: IconButton(
                onPressed: () {},
                iconSize: 30.0,
                color: Colors.white,
                icon: const Icon(Icons.photo_camera_back)),
          )
        ]));
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    //재생시간이 3초 이상이어야 뒤로가기 정상동작
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onForwardPressed() {}

  void onPlayPressed() {
    //이미 실행중이면 중지
    //실행중이 아니면 실행
    setState(() {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls(
      {required this.onPlayPressed,
      required this.onReversePressed,
      required this.onForwardPressed,
      required this.isPlaying,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
              onPressed: onReversePressed, iconData: Icons.rotate_left),
          renderIconButton(
              onPressed: onPlayPressed,
              iconData: isPlaying ? Icons.pause : Icons.play_arrow),
          renderIconButton(
              onPressed: onForwardPressed, iconData: Icons.rotate_right),
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
        onPressed: onPressed,
        iconSize: 30.0,
        color: Colors.white,
        icon: Icon(iconData));
  }
}
