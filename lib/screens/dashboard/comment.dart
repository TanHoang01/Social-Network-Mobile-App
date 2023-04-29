import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/comment_model.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

///add constants
import 'package:intl/intl.dart';

class atCommentScreen extends StatefulWidget {
  String uid;
  String postId;
  String ownerId;
  atCommentScreen(required,
      {Key? key,
      required this.uid,
      required this.postId,
      required this.ownerId})
      : super(key: key);

  @override
  _atCommentScreen createState() =>
      _atCommentScreen(this.uid, this.postId, this.ownerId);
}

class _atCommentScreen extends State<atCommentScreen>
    with SingleTickerProviderStateMixin {
  String uid = '';
  String postId = '';
  String ownerId = '';
  _atCommentScreen(this.uid, this.postId, this.ownerId);

  userModel user = userModel(
      id: '',
      email: '',
      fullName: '',
      avatar: '',
      favoriteList: [],
      saveList: [],
      follow: [],
      id_social: '');
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

  TextEditingController commentController = TextEditingController();
  GlobalKey<FormState> commentFormKey = GlobalKey<FormState>();

  List<commentModel> commentList = [];

  Future getCommentList() async {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('time', descending: false)
        .snapshots()
        .listen((value) {
      setState(() {
        commentList.clear();
        value.docs.forEach((element) {
          commentList.add(commentModel.fromDocument(element.data()));
        });
      });
    });
  }

  Future comment(String postId) async {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          'userId': uid,
          'ownerUsername': user.fullName,
          'ownerAvatar': user.avatar,
          'postId': postId,
          'content': commentController.text,
          'state': 'show',
          'time': "${DateFormat('y MMMM d, hh:mm:ss').format(DateTime.now())}"
        })
        .then((value1) => FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(value1.id)
            .update({'id': value1.id}))
        .then((value2) {
          if (uid != ownerId) {
            FirebaseFirestore.instance.collection('notifies').add({
              'idSender': uid,
              'idReceiver': ownerId,
              'avatarSender': user.avatar,
              'mode': 'public',
              'idPost': postId,
              'content': 'commented on your photo',
              'category': 'comment',
              'nameSender': user.fullName,
              'timeCreate':
                  "${DateFormat('y MMMM d, hh:mm a').format(DateTime.now())}"
            }).then((value3) {
              FirebaseFirestore.instance
                  .collection('notifies')
                  .doc(value3.id)
                  .update({'id': value3.id});
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    uid = userid!;
    getUserDetail();
    print('Day la :' + postId);
    getCommentList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent),
        child: Scaffold(
            body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Container(
                      margin:
                          EdgeInsets.only(left: 12, right: 12, top: 20 + 20),
                      child: Column(children: [
                        Row(children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child:
                                Icon(BootstrapIcons.caret_left_fill, size: 28),
                          ),
                          SizedBox(width: 32),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Comment',
                              style: TextStyle(
                                  fontFamily: 'Recoleta',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                        ]),
                        SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                              Container(
                                height: 440,
                                child: ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            SizedBox(height: 0),
                                    itemCount: commentList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 64,
                                                offset: Offset(8, 8),
                                              ),
                                              // BoxShadow(
                                              //   color: Colors.black.withOpacity(0.2),
                                              //   spreadRadius: 0,
                                              //   blurRadius: 4,
                                              //   offset: Offset(-4, -4),
                                              // ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        margin: EdgeInsets.only(top: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(4),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      child: Image.network(
                                                        commentList[index]
                                                            .ownerAvatar,
                                                        width: 32,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Container(
                                                      child: Text(
                                                    commentList[index]
                                                        .ownerUsername,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black),
                                                  ))
                                                ],
                                              ),
                                            ),
                                            Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: 327 + 24),
                                                margin: EdgeInsets.only(
                                                    top: 16,
                                                    left: 8,
                                                    bottom: 16,
                                                    right: 24),
                                                // height: 73,
                                                // width: 236 - 12,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(16.0),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 8, 0),
                                                  child: Text(
                                                    commentList[index].content,
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontFamily: "Urbanist",
                                                        fontSize: 16.0,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                )),
                                            Spacer(),
                                            Container()
                                            // Container(
                                            //   padding: EdgeInsets.all(8),
                                            //   alignment: Alignment.topRight,
                                            //   child: Icon(Iconsax.like_15,
                                            //       size: 16, color: Colors.black),
                                            // ),
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(height: 24),
                              Container(
                                height: 54,
                                padding: EdgeInsets.only(left: 24, right: 24),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                  color: Colors.grey,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    // SizedBox(width: 16),
                                    Container(
                                      width: 241,
                                      child: Expanded(
                                          child: Form(
                                        key: commentFormKey,
                                        child: TextField(
                                            controller: commentController,
                                            // onChanged: (value) => setState(() {
                                            //       comment = value;
                                            //     }),
                                            onEditingComplete: () {
                                              setState(() {
                                                commentController.clear();
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                              ),
                                              hintText: "Type your comment...",
                                            )),
                                      )),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          comment(postId);
                                          commentController.clear();
                                        });
                                        setState(() {});
                                      },
                                      child: Container(
                                        child: AnimatedContainer(
                                          alignment: Alignment.center,
                                          duration: Duration(milliseconds: 300),
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 64,
                                                offset: Offset(8, 8),
                                              ),
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            // padding: EdgeInsets.zero,
                                            alignment: Alignment.center,
                                            child: Icon(BootstrapIcons.send,
                                                size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]))
                      ]))))
        ])));
    // ])));
  }
}
