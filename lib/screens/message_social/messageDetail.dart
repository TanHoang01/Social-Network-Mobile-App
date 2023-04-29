import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/contentMessage.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';

class messageDetailScreen extends StatefulWidget {
  String uid;
  String uid2;
  String messagesId;
  messageDetailScreen(required,
      {Key? key,
      required this.uid,
      required this.uid2,
      required this.messagesId})
      : super(key: key);

  @override
  _messageDetailScreenState createState() =>
      _messageDetailScreenState(uid, uid2, this.messagesId);
}

class _messageDetailScreenState extends State<messageDetailScreen> {
  String uid = '';
  String uid2 = '';
  String messagesId = "";
  _messageDetailScreenState(this.uid, this.uid2, this.messagesId);
  late Content content = Content(
      contentId: '',
      userId: '',
      messageId: '',
      message: '',
      createAt: '',
      timeSendDetail: '');
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
  TextEditingController messageController = TextEditingController();
  GlobalKey<FormState> messageFormKey = GlobalKey<FormState>();
  String message = '';

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

  late DateTime date = DateTime.now();
  Future sendMessage() async {
    if (messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("contents").add({
        'content': messageController.text,
        'sendBy': uid,
        'messageId': messagesId,
        'timeSend': "${DateFormat('hh:mm a').format(DateTime.now())}",
        'timeSendDetail':
            "${DateFormat('y MMMM d, hh:mm:ss').format(DateTime.now())}"
      }).then((value) {
        FirebaseFirestore.instance
            .collection("messages_social")
            .doc(messagesId)
            .update({
          'contentList': FieldValue.arrayUnion([value.id]),
          'lastMessage': messageController.text,
          'lastTimeSend': "${DateFormat('hh:mm a').format(DateTime.now())}"
        });
        FirebaseFirestore.instance.collection("contents").doc(value.id).update({
          'contentId': value.id,
        }).then((value) {
          setState(() {
            messageController.clear();
          });
        });
      });
    }
  }

  late List contentList;
  late List<Content> chatting = [];

  Future getMessage2() async {
    FirebaseFirestore.instance
        .collection("messages_social")
        .doc(messagesId)
        .snapshots()
        .listen((value1) {
      FirebaseFirestore.instance
          .collection("contents")
          .orderBy('timeSendDetail', descending: false)
          .snapshots()
          .listen((value2) {
        setState(() {
          chatting.clear();
          contentList = value1.data()!["contentList"];
          value2.docs.forEach((element) {
            if (contentList.contains(element.data()['contentId'] as String)) {
              chatting.add(Content.fromDocument(element.data()));
            }
          });
        });
      });
    });
  }

  void initState() {
    super.initState();
    getUserDetail();
    getMessage2();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Container(
            // scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.only(left: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(BootstrapIcons.caret_left_fill,
                          size: 28, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.only(left: 28),
                  child: Text(
                    user.fullName,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 24.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 450 - 24,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36.0),
                        topRight: Radius.circular(36.0),
                      )),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(height: 32),
                                    Container(
                                      padding:
                                          EdgeInsets.only(left: 12, right: 12),
                                      child: ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  SizedBox(height: 16),
                                          itemCount: chatting.length,
                                          itemBuilder: (context, index) {
                                            return (uid ==
                                                    chatting[index].userId)
                                                ? Container(
                                                    // padding: EdgeInsets.only(
                                                    //     left: 28, right: 28),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          chatting[index]
                                                              .createAt,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Poppins",
                                                              fontSize: 10.0,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Spacer(),
                                                        Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth:
                                                                      264),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 16,
                                                                  left: 24,
                                                                  bottom: 16,
                                                                  right: 24),
                                                          // height: 73,
                                                          // width: 236 - 12,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        24.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        24.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        24.0)),
                                                            color: Colors.grey,
                                                          ),
                                                          child: Text(
                                                            chatting[index]
                                                                .message,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 12.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    // padding: EdgeInsets.only(
                                                    //     left: 28, right: 28),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          alignment: Alignment
                                                              .bottomLeft,
                                                          width: 32,
                                                          height: 32,
                                                          decoration:
                                                              new BoxDecoration(
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    // '${projects[index]!["background"]}'),
                                                                    user.avatar),
                                                                fit: BoxFit.cover),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth:
                                                                      254),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 16,
                                                                  left: 24,
                                                                  bottom: 16,
                                                                  right: 24),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        24.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        24.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        24.0)),
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    209,
                                                                    209,
                                                                    209),
                                                          ),
                                                          child: Text(
                                                            chatting[index]
                                                                .message,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 12.0,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Text(
                                                          chatting[index]
                                                              .createAt,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Poppins",
                                                              fontSize: 10.0,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                          }),
                                    ),
                                  ],
                                ))),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  width: 319 + 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey)),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 12),
                      Expanded(
                          child: Form(
                        key: messageFormKey,
                        child: TextField(
                            controller: messageController,
                            // onChanged: (value) => setState(() {
                            //       message = value;
                            //     }),
                            onEditingComplete: () {
                              setState(() {
                                // sendMessage();
                                getMessage2();
                                // messageController.clear();
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              hintText: "Type your message...",
                            )),
                      )),
                      SizedBox(width: 20),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: AnimatedContainer(
                          alignment: Alignment.center,
                          duration: Duration(milliseconds: 300),
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: 0,
                                blurRadius: 64,
                                offset: Offset(8, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                              margin: EdgeInsets.only(right: 8),
                              // padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                              child: IconButton(
                                  icon: Icon(BootstrapIcons.send_fill),
                                  iconSize: 18,
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      sendMessage();
                                      getMessage2();
                                    });
                                    setState(() {});
                                  })),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
