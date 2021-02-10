import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class Gallery extends StatefulWidget {
  Gallery(this.uid);
  final String uid;
  @override
  _GalleryState createState() => _GalleryState(uid);
}

class _GalleryState extends State<Gallery> {
  _GalleryState(this.uid);
  final String uid;

  List<String> itemList = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetList(
      uid: uid,
      itemList: itemList,
    ));
  }
}

class VideoWidget extends StatefulWidget {
  final bool play;
  final String url;

  const VideoWidget({Key key, @required this.url, @required this.play})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = new VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return new Container(
            height: MediaQuery.of(context).size.height * (1 / 3),
            child: Card(
              key: new PageStorageKey(widget.url),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Chewie(
                    key: new PageStorageKey(widget.url),
                    controller: ChewieController(
                      videoPlayerController: videoPlayerController,
                      aspectRatio: 1 / 2,
                      autoInitialize: true,
                      looping: false,
                      autoPlay: false,
                      // Errors can occur for example when trying to play a video
                      // from a non-existent URL
                      errorBuilder: (context, errorMessage) {
                        return Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class GetList extends StatelessWidget {
  final uid;
  final List<String> itemList;

  const GetList({Key key, @required this.uid, this.itemList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('VideoLink')
          .doc(uid)
          .collection(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final url = snapshot.data.docs;

        for (var link in url) {
          itemList.add(link['link'].toString());
          print(link['link'].toString());
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: new BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  key: PageStorageKey(key),
                  addAutomaticKeepAlives: true,
                  itemCount: itemList.isEmpty ? 0 : itemList.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        key: new PageStorageKey(
                          "keydata$index",
                        ),
                        child: VideoWidget(play: true, url: itemList[index])),
                  ),
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
