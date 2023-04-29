import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamestation/models/comment_watch_model..dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/models/watch_model.dart';
import 'package:gamestation/screens/watch/commentReel.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class OptionScreen extends StatefulWidget {
  final String? uid;
  final String? reelId;
  OptionScreen({Key? key, this.uid, this.reelId}) : super(key: key);
  @override
  _OptionScreenState createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  bool liked = false;
  String userId = '';
  Future like(String reelId, List likes) async {
    if (likes.contains(userId)) {
      FirebaseFirestore.instance.collection('reels').doc(reelId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      FirebaseFirestore.instance.collection('reels').doc(reelId).update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  late userModel user = userModel(
    avatar: '',
    email: '',
    favoriteList: [],
    fullName: '',
    id: '',
    saveList: [],
    follow: [],
    id_social: '',
  );
  late userModel owner = userModel(
    avatar: '',
    email: '',
    favoriteList: [],
    fullName: '',
    id: '',
    saveList: [],
    follow: [],
    id_social: '',
  );
  Future getOwnerDetail() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("id_social", isEqualTo: widget.uid)
        .snapshots()
        .listen((value) {
      setState(() {
        owner = userModel.fromDocument(value.docs.first.data());
      });
    });
  }

  Future getUserDetail() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("id_social", isEqualTo: userId)
        .snapshots()
        .listen((value) {
      setState(() {
        user = userModel.fromDocument(value.docs.first.data());
      });
    });
  }

  late reelModel reel = reelModel(
      id: '',
      idUser: '',
      caption: '',
      urlVideo: '',
      mode: '',
      timeCreate: '',
      state: '',
      ownerAvatar: '',
      likes: [],
      ownerUsername: '');

  Future getReelDetail() async {
    FirebaseFirestore.instance
        .collection("reels")
        .where("id", isEqualTo: widget.reelId)
        .snapshots()
        .listen((value) {
      setState(() {
        reel = reelModel.fromDocument(value.docs.first.data());
      });
    });
  }

  List<commentReelModel> listCMR = [];
  Future getNumbdercomment() async {
    FirebaseFirestore.instance
        .collection('reels')
        .doc(widget.reelId)
        .collection('comments')
        .snapshots()
        .listen((value) {
      setState(() {
        listCMR.clear();
        value.docs.forEach((element) {
          listCMR.add(commentReelModel.fromDocument(element.data()));
        });
      });
    });
  }

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    userId = userid!;
    print(userId);
    getReelDetail();
    getOwnerDetail();
    getUserDetail();
    getNumbdercomment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12 - 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 56 + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            (owner.avatar != '')
                                ? owner.avatar
                                : 'https://i.imgur.com/RUgPziD.jpg',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            owner.fullName,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                    width: 200,
                    child: Text(
                      reel.caption,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white),
                      maxLines: 1,
                    )),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: GestureDetector(
                          onTap: () {},
                          child: Icon(BootstrapIcons.file_earmark_music_fill,
                              color: Colors.white, size: 24)),
                    ),
                    SizedBox(width: 8),
                    Container(
                        alignment: Alignment.center,
                        width: 128,
                        child: Text(
                          'turmoilisme • Original sound',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white),
                          maxLines: 1,
                        )),
                    SizedBox(width: 8),
                    Container(
                      child: GestureDetector(
                          onTap: () {},
                          child: Icon(BootstrapIcons.geo_alt_fill,
                              color: Colors.white, size: 24)),
                    ),
                    SizedBox(width: 8),
                    Container(
                        alignment: Alignment.center,
                        width: 90,
                        child: Text(
                          'Thu Duc city',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white),
                          maxLines: 1,
                        )),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 0),
          Container(
            margin: EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        liked = !liked;
                        print(' Like r ne');
                        print(liked);
                        like(reel.id, reel.likes);
                      });
                    },
                    icon: (reel.likes.contains(userId))
                        ? Container(
                            // padding: EdgeInsets.only(left: 16),
                            alignment: Alignment.topRight,
                            child: Icon(BootstrapIcons.heart_fill,
                                size: 24, color: Colors.pink),
                          )
                        : Container(
                            // padding: EdgeInsets.only(left: 16),
                            alignment: Alignment.topRight,
                            child: Icon(BootstrapIcons.heart,
                                size: 24, color: Colors.white),
                          )),
                Container(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    (reel.likes.isEmpty) ? '0' : reel.likes.length.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: "Urbanist",
                        fontSize: 24.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: 14),
                Container(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => atCommentReelScreen(
                                      required,
                                      uid: userId,
                                      reelId: reel.id,
                                    ))));
                      },
                      child: Icon(BootstrapIcons.chat_left_dots,
                          color: Colors.white, size: 24)),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    listCMR.length.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: "Urbanist",
                        fontSize: 24.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: 14),
                Container(
                  child: GestureDetector(
                      onTap: () {},
                      child: Icon(BootstrapIcons.three_dots,
                          color: Colors.white, size: 24)),
                ),
                SizedBox(height: 24),
                Container(
                  child: GestureDetector(
                      onTap: () {},
                      child: Icon(BootstrapIcons.boombox,
                          color: Colors.white, size: 24)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
