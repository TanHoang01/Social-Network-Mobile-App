import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamestation/models/post_model.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/dashboard/create_post.dart';
import 'package:gamestation/screens/profile_social/followerWidget.dart';
import 'package:gamestation/screens/profile_social/personalInformation.dart';
import 'package:gamestation/screens/profile_social/seeAllFollower.dart';
import 'package:gamestation/screens/profile_social/seeAllFollowing.dart';
import 'package:gamestation/screens/profile_social/storage_method.dart';
import 'package:gamestation/screens/search_classify/components/image.dart';
import 'package:gamestation/screens/search_classify/components/video.dart';
import 'package:gamestation/screens/sign_in/sign_in_screen.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:math' as math;

///add constants

import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../controllers/firebase.dart';

class atProfileScreen extends StatefulWidget {
  String ownerId;
  atProfileScreen(required, {Key? key, required this.ownerId})
      : super(key: key);

  @override
  _atProfileScreen createState() => _atProfileScreen(ownerId);
}

class _atProfileScreen extends State<atProfileScreen>
    with SingleTickerProviderStateMixin {
  String userId = '';
  String ownerId = '';
  _atProfileScreen(this.ownerId);
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
  List idFollowing = [];
  Future getOwnerDetail() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("id_social", isEqualTo: ownerId)
        .snapshots()
        .listen((value) {
      setState(() {
        idFollowers.clear();
        owner = userModel.fromDocument(value.docs.first.data());
        photoUrl = owner.avatar;
        idFollowers = owner.favoriteList;
        idFollowing = owner.follow;
        Oid = owner.id_social;
      });
    });
  }

  List idFollowers = [];
  String Uid = '';
  String Oid = '';
  Future getUserDetail() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("id_social", isEqualTo: userId)
        .snapshots()
        .listen((value) {
      setState(() {
        user = userModel.fromDocument(value.docs.first.data());
        Uid = user.id_social;
      });
    });
  }

  Future followEvent(List follow) async {
    if (follow.contains(Oid)) {
      FirebaseFirestore.instance.collection('users').doc(Uid).update({
        'follow': FieldValue.arrayRemove([Oid]),
      });
      FirebaseFirestore.instance.collection('users').doc(Oid).update({
        'favoriteList': FieldValue.arrayRemove([Uid])
      });
    } else {
      FirebaseFirestore.instance.collection('users').doc(Uid).update({
        'follow': FieldValue.arrayUnion([Oid])
      });
      FirebaseFirestore.instance.collection('users').doc(Oid).update({
        'favoriteList': FieldValue.arrayUnion([Uid])
      });
    }
  }

  late List<postModel> postList = [];
  late List<postModel> postListImage = [];
  Future getPostList() async {
    FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: ownerId)
        .snapshots()
        .listen((value) {
      setState(() {
        postList.clear();
        postVideoList.clear();
        postListImage.clear();
        value.docs.forEach((element) {
          postList.add(postModel.fromDocument(element.data()));
        });
        postList.forEach((element) {
          if (element.urlVideo != '') {
            postVideoList.add(element);
          } else {
            postListImage.add(element);
          }
        });
      });
    });
  }

  late List<postModel> postSaveList = [];
  List saveIdList = [];
  Future getSavePostList() async {
    FirebaseFirestore.instance
        .collection('users')
        .where('id_social', isEqualTo: ownerId)
        .snapshots()
        .listen((value1) {
      FirebaseFirestore.instance
          .collection('posts')
          .snapshots()
          .listen((value2) {
        setState(() {
          saveIdList = value1.docs.first.data()["saveList"];
          postSaveList.clear();
          value2.docs.forEach((element) {
            if (saveIdList.contains(element.data()['id'] as String))
              postSaveList.add(postModel.fromDocument(element.data()));
          });
        });
      });
    });
  }

  late List<postModel> postVideoList = [];

  bool followed = false;
  final pageViewcontroller =
      PageController(initialPage: 0, keepPage: true, viewportFraction: 1);

  TabController? _tabController;

  Future storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'token': token}, SetOptions(merge: true));
  }

  String photoUrl = '';

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowCompression: false,
    );
    print('result');
    print(result);
    if (result != null) {
      photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics', File(result.files.first.path.toString()), false);

      await FirebaseFirestore.instance.collection("users").doc(Oid).update({
        'avatar': photoUrl,
      });
      return File(result.files.first.path.toString());
    }
  }

  String backgroundUrl = '';
  pickImageBackground() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowCompression: false,
    );
    print('result');
    print(result);
    if (result != null) {
      backgroundUrl = await StorageMethods().uploadImageToStorage(
          'uploads', File(result.files.first.path.toString()), false);

      await FirebaseFirestore.instance.collection("users").doc(Uid).update({
        'background': backgroundUrl,
      });
      return File(result.files.first.path.toString());
    }
  }

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    userId = userid!;
    super.initState();
    getOwnerDetail();
    getUserDetail();
    getPostList();
    getSavePostList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: AnnotatedRegion(
            value: SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.transparent),
            child: Scaffold(
              body: Stack(
                children: [
                  (ownerId != userId)
                      ? IconButton(
                          padding: EdgeInsets.only(left: 28),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(BootstrapIcons.caret_left_fill,
                              size: 28, color: Colors.black),
                        )
                      : Container(),
                  Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Container(
                          child: Column(
                        children: [
                          (Oid != Uid)
                              ? Container(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                    padding: EdgeInsets.only(left: 12, top: 24),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(BootstrapIcons.caret_left_fill,
                                        size: 28, color: Colors.black),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 24),
                          Container(
                            margin: EdgeInsets.only(left: 24, right: 24),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (userId == ownerId) {
                                        pickImage();
                                      }
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: new BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                // userList[index]
                                                //     .avatar
                                                (photoUrl != '')
                                                    ? photoUrl
                                                    : 'https://i.imgur.com/RUgPziD.jpg'),
                                            fit: BoxFit.cover),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 32),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        (Oid != Uid)
                                            ? Container(
                                                child: Text(
                                                  (owner.fullName == null)
                                                      ? ''
                                                      : owner.fullName,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      (owner.fullName == null)
                                                          ? ''
                                                          : owner.fullName,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 48, right: 3),
                                                    child: IconButton(
                                                      padding: EdgeInsets.only(
                                                          left: 28),
                                                      onPressed: () {
                                                        signOut(context);
                                                      },
                                                      icon: Icon(
                                                          BootstrapIcons
                                                              .box_arrow_left,
                                                          size: 28,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      (postList.length == 0)
                                                          ? '0'
                                                          : postList.length
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "Posts",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 32),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      (owner.favoriteList
                                                                  .length ==
                                                              0)
                                                          ? '0'
                                                          : owner.favoriteList
                                                              .length
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "Followers",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 32),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      (owner.follow.length == 0)
                                                          ? '0'
                                                          : owner.follow.length
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: ((context) =>
                                                                  seeAllFollowing(
                                                                    idUser:
                                                                        idFollowing,
                                                                  ))));
                                                    },
                                                    child: Container(
                                                      child: Text(
                                                        "Following",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          (Oid != Uid)
                              ? Container(
                                  padding: EdgeInsets.only(left: 12, top: 24),
                                  child: (Row(children: [
                                    (user.follow.contains(Oid))
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                followed = !followed;
                                                followEvent(user.follow);
                                              });
                                            },
                                            child: Container(
                                              width: 72 + 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4)),
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text('Following',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                followed = !followed;
                                                followEvent(user.follow);
                                              });
                                            },
                                            child: Container(
                                              width: 72,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4)),
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text('Follow',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
                                              ),
                                            ),
                                          ),
                                  ])),
                                )
                              : Container(),
                          SizedBox(height: 16),
                          (idFollowers.length != 0)
                              ? Container(
                                  margin: EdgeInsets.only(left: 12, right: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          "Followers",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: ((context) => seeAll(
                                                        idUser: idFollowers,
                                                      ))));
                                        },
                                        child: Text(
                                          "See all",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 8),
                          (idFollowers.length != 0)
                              ? Container(
                                  // width: 367,
                                  height: 48 + 6,
                                  child: ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: idFollowers.length,
                                      itemBuilder: (context, index) {
                                        return followerWidget(
                                            uid: idFollowers[index].toString());
                                      }),
                                )
                              : Container(),
                          SizedBox(height: 24),
                          Container(
                            height: 56,
                            width: 375 + 24,
                            child: Container(
                              color: Colors.transparent,
                              child: TabBar(
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.transparent,
                                indicator: UnderlineTabIndicator(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1)),
                                //For Indicator Show and Customization
                                indicatorColor: Colors.black,
                                tabs: [
                                  Tab(
                                    icon: Icon(BootstrapIcons.grid_3x3_gap,
                                        color: Colors.black, size: 24),
                                  ),
                                  Tab(
                                    icon: Icon(BootstrapIcons.play_circle,
                                        color: Colors.black, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              child: TabBarView(
                            controller: _tabController,
                            children: [
                              profileTabPostScreen(postList),
                              profileTabVideoScreen(postVideoList),
                            ],
                          ))
                        ],
                      )))
                ],
              ),
            )));
  }

  profileTabPostScreen(List postList) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: GridView.custom(
        gridDelegate: (postList.length >= 4)
            ? SliverQuiltedGridDelegate(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [
                  QuiltedGridTile(2, 1),
                  QuiltedGridTile(1, 1),
                  QuiltedGridTile(1, 1),
                  QuiltedGridTile(1, 2),
                ],
              )
            : SliverQuiltedGridDelegate(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [QuiltedGridTile(1, 1)],
              ),
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            // (postList.length == 0)
            //     ? Container()
            //     :
            return (postList[index].urlImage != '')
                ? ImageWidget(
                    src: postList[index].urlImage,
                    postId: postList[index].id,
                    uid: userId,
                    position: index.toString(),
                  )
                : VideoWidget(
                    src: postList[index].urlVideo,
                    postId: postList[index].id,
                    uid: userId,
                    position: index.toString(),
                  );
          },
          childCount: postList.length,
        ),
      ),
    );
  }

  profileTabVideoScreen(List postList) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: postList.length,
        itemBuilder: (context, index) {
          // (postList.length == 0)
          //     ? Container()
          //     :
          return VideoWidget(
            src: postList[index].urlVideo,
            postId: postList[index].id,
            uid: userId,
            position: index.toString(),
          );
        },
      ),
    );
  }

  profileTabReelScreen(List postList) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: postList.length,
        itemBuilder: (context, index) {
          // (postList.length == 0)
          //     ? Container()
          //     :
          return VideoWidget(
            src: postList[index].urlVideo,
            postId: postList[index].id,
            uid: userId,
            position: index.toString(),
          );
        },
      ),
    );
  }
}
