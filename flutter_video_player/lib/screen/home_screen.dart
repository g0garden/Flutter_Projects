import 'package:flutter/material.dart';
import 'package:flutter_video_player/component/custom_video_player.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: video == null ? renderEmpty() : renderVideo());
  }

  Widget renderVideo() {
    return Center(
        child: CustomVideoPlayer(
      video: video!,
    ));
  }

  Widget renderEmpty() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: getBoxDecoration(),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Logo(onTap: onLogoTap),
        const SizedBox(height: 20),
        _AppName()
      ]),
    );
  }

//로그클릭시, video 선택가능하도록
  void onLogoTap() async {
    final video = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      setState(() {
        this.video = video;
      });
    }
  }
}

BoxDecoration getBoxDecoration() {
  return const BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF2A3A7C), Color(0xFF000118)]));
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;
  const _Logo({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, child: Image.asset("asset/image/logo.png"));
  }
}

class _AppName extends StatelessWidget {
  const _AppName({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.w300);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "VIDEO",
          style: textStyle,
        ),
        Text("PLAYER", style: textStyle.copyWith(fontWeight: FontWeight.w700))
      ],
    );
  }
}
