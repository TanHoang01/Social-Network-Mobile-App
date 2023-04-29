import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/watch_model.dart';
import 'package:gamestation/screens/watch/contentScreen.dart';
import 'package:gamestation/screens/watch/createReel.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

///add constants
import 'package:video_player/video_player.dart';

class atWatchScreen extends StatefulWidget {
  String uid;
  atWatchScreen(required, {Key? key, required this.uid}) : super(key: key);

  @override
  _atWatchScreen createState() => _atWatchScreen();
}

class _atWatchScreen extends State<atWatchScreen>
    with SingleTickerProviderStateMixin {
  String userId = '';

  List<reelModel> reelList = [];
  List videoList = [];
  List ownerId = [];
  List reelId = [];
  Future getReelList() async {
    FirebaseFirestore.instance
        .collection("reels")
        .orderBy('timeCreate', descending: true)
        .snapshots()
        .listen((value) {
      setState(() {
        reelList.clear();
        value.docs.forEach((element) {
          reelList.add(reelModel.fromDocument(element.data()));
        });
        print(reelList.length);
      });
    });
  }

  late SwiperController swiperController = SwiperController();
  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    userId = userid!;
    print(userId);
    getReelList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        swiperController.next();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future refreshController() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return refreshController();
        },
        child: Container(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Swiper(
                controller: swiperController,
                itemBuilder: (BuildContext context, int index) {
                  return ContentScreen(
                    src: reelList[index].urlVideo,
                    uid: reelList[index].idUser,
                    reelId: reelList[index].id,
                  );
                },
                itemCount: reelList.length,
                scrollDirection: Axis.vertical,
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 24 + 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        // SizedBox(width: 117.5),
                        Container(
                          child: Text(
                            'Watch',
                            style: TextStyle(
                                fontFamily: 'Recoleta',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        // SizedBox(width: 117.5),
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => atCreateReelScreen(
                                          context,
                                          uid: userId))));
                            },
                            child: Icon(BootstrapIcons.camera_fill,
                                size: 28, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              // ContentScreen(like: like,)
            ],
          ),
        ),
      ),
    );
  }
}
