import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:video_player/video_player.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
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
        child: Center(
          child: Container(
            height: videoFile != null
                ? MediaQuery.of(context).size.height * (80 / 100)
                : MediaQuery.of(context).size.height * (5 / 100),
            width: videoFile != null
                ? MediaQuery.of(context).size.width * (100 / 100)
                : MediaQuery.of(context).size.width * (027 / 100),
            child: videoFile == null
                ? Center(
                    child: Container(
                      child: RaisedButton(
                        child: Row(
                          children: [Text('Record'), Icon(Icons.videocam)],
                        ),
                        onPressed: () {
                          _camera();
                        },
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: videoFile != null
                            ? MediaQuery.of(context).size.height * (80 / 100)
                            : MediaQuery.of(context).size.height * (5 / 100),
                        width: videoFile != null
                            ? MediaQuery.of(context).size.width * (100 / 100)
                            : MediaQuery.of(context).size.width * (027 / 100),
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
                                        looping: true,
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
                                              (35 / 100),
                                          child: RaisedButton(
                                            child: Row(
                                              children: [
                                                Text('Upload'),
                                                Icon(Icons.videocam)
                                              ],
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                              );
                                              FirebaseStorage storage =
                                                  FirebaseStorage.instance;

                                              Reference rootReference =
                                                  storage.ref();

                                              Reference videoFolderReference =
                                                  rootReference
                                                      .child("Recordings")
                                                      .child(
                                                          "${DateTime.now().millisecondsSinceEpoch}");
                                              videoFolderReference
                                                  .putFile(videoFile)
                                                  .whenComplete(
                                                () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainScreen(),
                                                    ),
                                                  );
                                                },
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
      ),
    );
  }
}

//
