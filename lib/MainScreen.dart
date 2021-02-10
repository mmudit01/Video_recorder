import 'package:camera_recorder/Gallery.dart';
import 'package:camera_recorder/login_page.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:video_player/video_player.dart';

class MainScreen extends StatefulWidget {
  MainScreen(this.uid);
  final String uid;
  @override
  _MainScreenState createState() => _MainScreenState();
}

AnimationController _animationController;
Animation<Color> _colorTween;
TickerProvider value;
void initState() {
  _animationController = AnimationController(
    duration: Duration(milliseconds: 1800),
    vsync: value,
  );
  _colorTween = _animationController
      .drive(ColorTween(begin: Colors.yellow, end: Colors.blue));
  _animationController.repeat();
}

class _MainScreenState extends State<MainScreen> {
  File videoFile;

  _camera() async {
    File video = await ImagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 10),
    );
    if (video != null) {
      setState(() {
        videoFile = video;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                height: videoFile != null
                    ? MediaQuery.of(context).size.height * (80 / 100)
                    : MediaQuery.of(context).size.height * (20 / 100),
                width: videoFile != null
                    ? MediaQuery.of(context).size.width * (100 / 100)
                    : MediaQuery.of(context).size.width * (027 / 100),
                child: videoFile == null
                    ? Center(
                        child: Column(
                          children: [
                            Container(
                              child: RaisedButton(
                                child: Row(
                                  children: [
                                    Text('Record'),
                                    SizedBox(width: 5),
                                    Icon(Icons.videocam)
                                  ],
                                ),
                                onPressed: () {
                                  print(widget.uid);
                                  _camera();
                                },
                              ),
                            ),
                            Container(
                              child: RaisedButton(
                                child: Row(
                                  children: [
                                    Text('Gallery'),
                                    SizedBox(width: 5),
                                    Icon(Icons.picture_in_picture_alt_sharp),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Gallery(widget.uid),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            height: videoFile != null
                                ? MediaQuery.of(context).size.height *
                                    (80 / 100)
                                : MediaQuery.of(context).size.height *
                                    (5 / 100),
                            width: videoFile != null
                                ? MediaQuery.of(context).size.width *
                                    (100 / 100)
                                : MediaQuery.of(context).size.width *
                                    (027 / 100),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: mounted
                                  ? Column(
                                      children: [
                                        Chewie(
                                          controller: ChewieController(
                                            videoPlayerController:
                                                VideoPlayerController.file(
                                                    videoFile),
                                            aspectRatio: 1 / 2,
                                            autoPlay: true,
                                            looping: false,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  (5 / 100),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  (36 / 100),
                                              child: RaisedButton(
                                                child: Row(
                                                  children: [
                                                    Text('Record Again'),
                                                    Icon(Icons.videocam)
                                                  ],
                                                ),
                                                onPressed: () {
                                                  _camera();
                                                },
                                              ),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  (5 / 100),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  (19 / 100),
                                              child: RaisedButton(
                                                child: Row(
                                                  children: [
                                                    Text('Ok'),
                                                    Icon(Icons.videocam)
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  showDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      elevation: 0,
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            CircularProgressIndicator(
                                                              valueColor:
                                                                  _colorTween,
                                                            ),
                                                            Text(
                                                                'Uploading...'),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                  FirebaseStorage storage =
                                                      FirebaseStorage.instance;

                                                  Reference rootReference =
                                                      storage.ref();

                                                  Reference
                                                      videoFolderReference =
                                                      rootReference
                                                          .child(widget.uid)
                                                          .child(
                                                              "${DateTime.now().millisecondsSinceEpoch}");
                                                  await videoFolderReference
                                                      .putFile(videoFile);
                                                  var videoLink =
                                                      await videoFolderReference
                                                          .getDownloadURL();
                                                  FirebaseFirestore.instance
                                                      .collection('VideoLink')
                                                      .doc(widget.uid)
                                                      .collection(widget.uid)
                                                      .doc(
                                                          "${DateTime.now().millisecondsSinceEpoch}")
                                                      .set(
                                                    {
                                                      'link': videoLink,
                                                    },
                                                  );
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainScreen(
                                                              widget.uid),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final googleSignIn = GoogleSignIn();
                await FirebaseAuth.instance.signOut();
                final facebookLogin = FacebookLogin();
                await facebookLogin.logOut();
                await googleSignIn.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(20),
                alignment: Alignment.topRight,
                child: Text(
                  'LogOut',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
