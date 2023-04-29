import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/post_model.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/notification/postNotification.dart';
import 'package:gamestation/screens/profile_social/image.dart';
import 'package:gamestation/screens/profile_social/profile.dart';
import 'package:gamestation/screens/profile_social/video.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class atSearchScreen extends StatefulWidget {
  String uid;
  atSearchScreen(required, {Key? key, required this.uid}) : super(key: key);

  @override
  _atSearchScreen createState() => _atSearchScreen(uid);
}

class _atSearchScreen extends State<atSearchScreen>
    with SingleTickerProviderStateMixin {
  String uid = '';
  _atSearchScreen(this.uid);
  TextEditingController searchController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String search = '';
  List<postModel> postListCaption = [];

  Future searchCaption() async {
    FirebaseFirestore.instance.collection("posts").snapshots().listen((value) {
      setState(() {
        postListCaption.clear();
        postList.clear();
        value.docs.forEach((element) {
          postListCaption.add(postModel.fromDocument(element.data()));
        });

        postListCaption.forEach((element) {
          print(
              (element.caption.toUpperCase().contains(search.toUpperCase())) ==
                  true);
          if (((element.caption + " ")
                  .toUpperCase()
                  .contains(search.toUpperCase())) ==
              true) {
            postList.add(element);
            print(postList.length);
          }
        });
        if (postList.isEmpty) {}
      });
    });
  }

  List<userModel> userSearch = [];
  Future searchName() async {
    FirebaseFirestore.instance.collection("users").snapshots().listen((value) {
      setState(() {
        userSearch.clear();
        userList.clear();
        value.docs.forEach((element) {
          userSearch.add(userModel.fromDocument(element.data()));
        });

        userSearch.forEach((element) {
          print((element.email.toUpperCase().contains(search.toUpperCase())) ==
              true);
          if (((element.email + " ")
                  .toUpperCase()
                  .contains(search.toUpperCase())) ==
              true) {
            userList.add(element);
            print(userList.length);
          }
        });
        userList.forEach((element) {
          print(element.id);
          if (element.id == uid) {
            setState(() {
              userList.remove(element);
            });
          }
        });
      });
    });
  }

  late List<postModel> postList = [];
  Future getPostList() async {
    FirebaseFirestore.instance
        .collection('posts')
        .where('state', isEqualTo: "show")
        .snapshots()
        .listen((value) {
      setState(() {
        postList.clear();
        value.docs.forEach((element) {
          postList.add(postModel.fromDocument(element.data()));
        });
      });
    });
  }

  List<userModel> userList = [];

  Future getAllUser() async {
    FirebaseFirestore.instance.collection("users").get().then((value) {
      setState(() {
        userList.clear();
        value.docs.forEach((element) {
          userList.add(userModel.fromDocument(element.data()));
        });
        userList.forEach((element) {
          print(element.id);
          if (element.id == uid) {
            setState(() {
              userList.remove(element);
            });
          }
        });
        print(userList);
      });
    });
    setState(() {});
  }

  File? imageFile;
  String link = '';

  late String urlImage = '';

  @override
  void initState() {
    getPostList();
    getAllUser();
    super.initState();
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
          Container(
            padding: EdgeInsets.only(top: 32, right: 16, left: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            alignment: Alignment.topLeft,
                            child:
                                Icon(BootstrapIcons.caret_left_fill, size: 30)),
                      ),
                      Spacer(),
                      Container(
                        alignment: Alignment.center,
                        child: Form(
                          // key: formKey,
                          child: Container(
                            width: 327 - 30,
                            height: 40,
                            padding: EdgeInsets.only(left: 2, right: 1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                border: Border.all(color: Colors.grey)),
                            alignment: Alignment.topCenter,
                            child: TextFormField(
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                                controller: searchController,
                                keyboardType: TextInputType.text,
                                onChanged: (val) {
                                  search = val;
                                  searchCaption();
                                  searchName();
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                        Icon(BootstrapIcons.search,
                                            size: 20, color: Colors.black)
                                      ])),
                                  border: InputBorder.none,
                                  hintText: "What are you looking for?",
                                  hintStyle: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Post',
                      style: TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                      width: 327 + 24,
                      padding: EdgeInsets.only(bottom: 8),
                      // height: 400,
                      child: GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: postList.length,
                        // userList.length.clamp(0, 3),
                        itemBuilder: (context, index) {
                          // (postList.length == 0)
                          //     ? Container()
                          //     :
                          return (postList[index].urlImage != '')
                              ? Container(
                                  child: ImageWidget(
                                    src: postList[index].urlImage,
                                    postId: postList[index].id,
                                    uid: uid,
                                    position: index.toString(),
                                  ),
                                )
                              : Container(
                                  child: VideoWidget(
                                    src: postList[index].urlVideo,
                                    postId: postList[index].id,
                                    uid: uid,
                                    position: index.toString(),
                                  ),
                                );
                        },
                      )),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'User',
                      style: TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        child: Container(
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.only(top: 8),
                              shrinkWrap: true,
                              itemCount: userList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    width: 327 + 24,
                                    margin: EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    atProfileScreen(
                                                      context,
                                                      ownerId:
                                                          userList[index].id,
                                                    ))));
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            margin: EdgeInsets.only(
                                                left: 16, bottom: 16, top: 16),
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      // userList[index]
                                                      //     .avatar
                                                      (userList[index].avatar !=
                                                              '')
                                                          ? userList[index]
                                                              .avatar
                                                          : 'https://i.imgur.com/RUgPziD.jpg'),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          Container(
                                            width: 183 + 24,
                                            margin: EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userList[index].fullName,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  userList[index].email,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ));
                              }),
                        )),
                  )
                ],
              ),
            ),
            margin: EdgeInsets.only(bottom: 32 + 24),
          )
        ])));
  }
}
