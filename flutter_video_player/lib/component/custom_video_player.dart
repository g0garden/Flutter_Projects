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
  Duration currentPosition = Duration(); //영상의 현재 재생위치
  bool showControls = false;

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

    videoController!.addListener(() {
      final currentPosition = videoController!.value.position;

      setState(() {
        this.currentPosition = currentPosition;
      });
    });

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
        child: GestureDetector(
          onTap: () {
            setState(() {
              showControls = !showControls;
            });
          },
          child: Stack(children: [
            VideoPlayer(videoController!),
            if (showControls)
              _Controls(
                  onPlayPressed: onPlayPressed,
                  onReversePressed: onReversePressed,
                  onForwardPressed: onForwardPressed,
                  isPlaying: videoController!.value.isPlaying),
            if (showControls) _NewVideo(onPressed: onNewVideoPressed),
            _SliderBottom(
                currentPosition: currentPosition,
                maxPosition: videoController!.value.duration,
                onSliderChanged: onSliderChanged)
          ]),
        ));
  }

  void onSliderChanged(double val) {
    //onChanged는 slider를 움직일때 호출됨
    //즉 여기서 컨트롤러한테 알려줘야함 슬라이더위치 지금 여기니까 너도 재생위치 변경해
    videoController!.seekTo(Duration(seconds: val.toInt()));
  }

  //뒤로 3초
  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    //재생시간이 3초 이상이어야 뒤로가기 정상동작
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onNewVideoPressed() {}

  //앞으로 3초
  void onForwardPressed() {
    final maxPositioin = videoController!.value.duration;
    final currentPosition = videoController!.value.position;

    Duration position = maxPositioin;

    //재생시간이 3초 이상 남아있어야 3초 앞으로 가기 정상동작
    if ((maxPositioin - Duration(seconds: 3)).inSeconds <
        currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

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
      height: MediaQuery.of(context).size.height,
      child: Row(
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

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewVideo({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 0,
        child: IconButton(
            onPressed: onPressed,
            iconSize: 30.0,
            color: Colors.white,
            icon: const Icon(Icons.photo_camera_back)));
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom(
      {super.key,
      required this.currentPosition,
      required this.maxPosition,
      required this.onSliderChanged});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
                '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white)),
            Expanded(
              child: Slider(
                  value: currentPosition.inSeconds.toDouble(),
                  onChanged: onSliderChanged,
                  max: maxPosition.inSeconds.toDouble()),
            ),
            Text(
                '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
