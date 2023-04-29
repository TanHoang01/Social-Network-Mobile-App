import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/post_model.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/dashboard/comment.dart';
import 'package:gamestation/screens/dashboard/dialog.dart';
import 'package:gamestation/screens/dashboard/postVideoWidget.dart';
import 'package:gamestation/screens/profile_social/profile.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class postNotification extends StatefulWidget {
  String uid;
  String postId;
  postNotification(BuildContext context,
      {Key? key, required this.uid, required this.postId})
      : super(key: key);
  @override
  _postNotificationState createState() =>
      _postNotificationState(this.uid, this.postId);
}

class _postNotificationState extends State<postNotification> {
  bool liked = false;
  bool silent = false;
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
  String uid = '';
  String postId = '';

  _postNotificationState(this.uid, this.postId);

  Future getUserDetail() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("id_social", isEqualTo: uid)
        .snapshots()
        .listen((value) {
      setState(() {
        user = userModel.fromDocument(value.docs.first.data());
      });
    });
  }

  postModel post = postModel(
      id: '',
      idUser: '',
      caption: '',
      urlImage: '',
      urlVideo: '',
      mode: '',
      timeCreate: '',
      state: '',
      ownerAvatar: '',
      likes: [],
      ownerUsername: '');
  Future getPost() async {
    FirebaseFirestore.instance
        .collection("posts")
        .where('id', isEqualTo: postId)
        .snapshots()
        .listen((value) {
      setState(() {
        post = postModel.fromDocument(value.docs.first.data());
      });
    });
  }

  late DateTime timeCreate = DateTime.now();

  Future like(String postId, List likes, String ownerId) async {
    if (likes.contains(uid)) {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      }).whenComplete(() {
        if (uid != ownerId) {
          FirebaseFirestore.instance.collection('notifies').add({
            'idSender': uid,
            'idReceiver': ownerId,
            'avatarSender': user.avatar,
            'mode': 'public',
            'idPost': postId,
            'content': 'liked your photo',
            'category': 'like',
            'nameSender': user.fullName,
            'timeCreate':
                "${DateFormat('y MMMM d, hh:mm a').format(DateTime.now())}"
          }).then((value) {
            FirebaseFirestore.instance
                .collection('notifies')
                .doc(value.id)
                .update({'id': value.id});
          });
        }
      });
    }
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    getUserDetail();
    getPost();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 32),
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(BootstrapIcons.caret_left_fill,
                                size: 28, color: Colors.black),
                          ),
                          Spacer(),
                          Container()
                        ]),
                    SizedBox(height: 16),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => atProfileScreen(
                                          required,
                                          ownerId: post.idUser)));
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      (post.ownerAvatar != '')
                                          ? post.ownerAvatar
                                          : 'https://i.imgur.com/RUgPziD.jpg',
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                    child: Text(
                                  post.ownerUsername,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ))
                              ],
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              if (uid == post.idUser) {
                                hidePostDialog(context, post.id);
                              } else {}
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.topRight,
                              child: Icon(BootstrapIcons.three_dots,
                                  size: 24, color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                    (post.urlImage != '')
                        ? Container(
                            width: 360,
                            height: 340,
                            padding: EdgeInsets.only(top: 8, bottom: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                post.urlImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : (post.urlVideo != '')
                            ? postVideoWidget(context, src: post.urlVideo)
                            : Container(),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  liked = !liked;
                                  like(post.id, post.likes, post.idUser);
                                });
                              },
                              icon: (post.likes.contains(uid))
                                  ? Container(
                                      padding: EdgeInsets.only(left: 8),
                                      alignment: Alignment.topRight,
                                      child: Icon(BootstrapIcons.heart_fill,
                                          size: 24, color: Colors.pink),
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(left: 8),
                                      alignment: Alignment.topRight,
                                      child: Icon(BootstrapIcons.heart,
                                          size: 24, color: Colors.black),
                                    )),
                          GestureDetector(
                            onTap: () {
                              //likes post
                            },
                            child: Container(
                                padding: EdgeInsets.only(left: 8),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  (post.likes.isEmpty)
                                      ? '0'
                                      : post.likes.length.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                          ),
                          IconButton(
                            padding: EdgeInsets.only(left: 8),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => atCommentScreen(
                                            required,
                                            uid: uid,
                                            postId: post.id,
                                            ownerId: post.idUser,
                                          ))));
                            },
                            icon: Container(
                              child: Icon(BootstrapIcons.chat_left_dots,
                                  size: 24, color: Colors.black),
                            ),
                          ),
                          // Container(
                          //     margin: EdgeInsets.only(left: 8),
                          //     alignment: Alignment.centerLeft,
                          //     child: Text(
                          //       '24',
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         color: Colors.black,
                          //         fontFamily: 'Urbanist',
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     )),
                          Spacer(),
                          Container(
                            decoration:
                                BoxDecoration(color: Colors.transparent),
                          )
                        ],
                      ),
                    ),
                    // SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        //likes post
                      },
                      child: Container(
                          width: 327 + 24,
                          margin: EdgeInsets.only(left: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            post.caption,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                          )),
                    ),
                    SizedBox(height: 8),
                    Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          post.timeCreate,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
