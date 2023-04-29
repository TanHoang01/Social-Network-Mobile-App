import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gamestation/models/post_model.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/dashboard/comment.dart';
import 'package:gamestation/screens/dashboard/create_post.dart';
import 'package:gamestation/screens/dashboard/dialog.dart';
import 'package:gamestation/screens/dashboard/postVideoWidget.dart';
import 'package:gamestation/screens/profile_social/profile.dart';
import 'package:gamestation/screens/search_classify/basicSearch.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<postModel> postList = [];
  Future getPostList() async {
    FirebaseFirestore.instance
        .collection("posts")
        .orderBy('timeCreate', descending: false)
        .snapshots()
        .listen((value) {
      setState(() {
        postList.clear();
        value.docs.forEach((element) {
          if (element.data()["state"] == "show") {
            postList.add(postModel.fromDocument(element.data()));
          }
        });
      });
    });
  }

  late VideoPlayerController _videoPlayerController;

  late ChewieController _chewieController =
      ChewieController(videoPlayerController: _videoPlayerController);
  bool check = false;
  bool play = false;

  Future<void> controlOnRefresh() async {
    setState(() {});
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

  FirebaseAuth auth = FirebaseAuth.instance;
  bool liked = false;
  bool silent = false;
  String uid = '';

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    uid = userid!;
    getUserDetail();
    getPostList();
    print(uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent),
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () {
              return getPostList();
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                ),
                Container(
                  padding: EdgeInsets.only(top: 32, right: 16, left: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          user.fullName,
                          style: TextStyle(
                            fontFamily: 'Recoleta',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Container(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            atCreatePostScreen(required,
                                                uid: '')),
                                  );
                                },
                                child: AnimatedContainer(
                                  alignment: Alignment.topRight,
                                  duration: Duration(milliseconds: 300),
                                  height: 24,
                                  width: 24,
                                  child: Container(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        BootstrapIcons.folder_plus,
                                        size: 22,
                                        color: Colors.black,
                                      )),
                                ),
                              )),
                          SizedBox(width: 16),
                          Container(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => atSearchScreen(
                                          required,
                                          uid: user.id_social)),
                                );
                              },
                              child: Container(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.topRight,
                                  child: const Icon(
                                    BootstrapIcons.search_heart,
                                    size: 22,
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                        top: 88, left: 16, right: 16, bottom: 56),
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(height: 16),
                        itemCount: postList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      atProfileScreen(required,
                                                          ownerId:
                                                              postList[index]
                                                                  .idUser)));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(4),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                  postList[index].ownerAvatar,
                                                  width: 32,
                                                  height: 32,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                                child: Text(
                                              postList[index].ownerUsername,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ))
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          if (uid == postList[index].idUser) {
                                            if (postList[index].state ==
                                                'show') {
                                              hidePostDialog(
                                                  context, postList[index].id);
                                            } else {
                                              // showPostDialog(
                                              //     context, postList[index].id);
                                            }
                                          } else {
                                            // savePostDialog(context,
                                            //     postList[index].id, uid);
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            BootstrapIcons.three_dots,
                                            size: 24,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                (postList[index].urlImage != '')
                                    ? Container(
                                        width: 360,
                                        height: 340,
                                        padding:
                                            EdgeInsets.only(top: 8, bottom: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            postList[index].urlImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : postVideoWidget(context,
                                        src: postList[index].urlVideo),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              liked = !liked;
                                              like(
                                                  postList[index].id,
                                                  postList[index].likes,
                                                  postList[index].idUser);
                                            });
                                          },
                                          icon: (postList[index]
                                                  .likes
                                                  .contains(uid))
                                              ? Container(
                                                  padding:
                                                      EdgeInsets.only(left: 8),
                                                  alignment: Alignment.topRight,
                                                  child: Icon(
                                                      BootstrapIcons.heart_fill,
                                                      size: 24,
                                                      color: Colors.pink),
                                                )
                                              : Container(
                                                  padding:
                                                      EdgeInsets.only(left: 8),
                                                  alignment: Alignment.topRight,
                                                  child: Icon(
                                                    BootstrapIcons.heart,
                                                    size: 24,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                      GestureDetector(
                                        onTap: () {
                                          //likes post
                                        },
                                        child: Container(
                                            padding: EdgeInsets.only(left: 8),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              (postList[index].likes.isEmpty)
                                                  ? '0'
                                                  : postList[index]
                                                      .likes
                                                      .length
                                                      .toString(),
                                              style: TextStyle(
                                                fontSize: 20,
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
                                                  builder: ((context) =>
                                                      atCommentScreen(
                                                        required,
                                                        uid: uid,
                                                        postId:
                                                            postList[index].id,
                                                        ownerId: postList[index]
                                                            .idUser,
                                                      ))));
                                        },
                                        icon: Container(
                                          child: Icon(
                                            BootstrapIcons.chat_left_dots,
                                            size: 24,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      (postList[index].urlVideo != '')
                                          ? IconButton(
                                              onPressed: () {
                                                //save post
                                              },
                                              icon: (silent == true)
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          right: 8),
                                                      child: Icon(
                                                          BootstrapIcons
                                                              .volume_mute,
                                                          size: 24,
                                                          color: Colors.grey),
                                                    )
                                                  : Container(
                                                      margin: EdgeInsets.only(
                                                          right: 8),
                                                      child: Icon(
                                                        BootstrapIcons
                                                            .volume_up,
                                                        size: 24,
                                                        color: Colors.black,
                                                      ),
                                                    ))
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent),
                                            )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {
                                    //likes post
                                  },
                                  child: Container(
                                      width: 327 + 24,
                                      margin: EdgeInsets.only(left: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        postList[index].caption,
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
                                      postList[index].timeCreate,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                              ],
                            ),
                          );
                        }))
              ],
            ),
          ),
        ));
  }
}
