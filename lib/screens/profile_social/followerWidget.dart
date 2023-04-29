import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/profile_social/profile.dart';
import 'package:video_player/video_player.dart';

class followerWidget extends StatefulWidget {
  String uid;

  followerWidget({Key? key, required this.uid}) : super(key: key);

  bool liked = false;
  @override
  _followerWidgetState createState() => _followerWidgetState(this.uid);
}

class _followerWidgetState extends State<followerWidget> {
  String uid = '';
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

  _followerWidgetState(this.uid);

  Future getOwnerDetail() async {
    print(uid.replaceAll(r'[', '').replaceAll(r']', ''));
    FirebaseFirestore.instance
        .collection("users")
        .where("id_social",
            isEqualTo: uid.replaceAll(r'[', '').replaceAll(r']', ''))
        .snapshots()
        .listen((value) {
      setState(() {
        owner = userModel.fromDocument(value.docs.first.data());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getOwnerDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _liked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      atProfileScreen(required, ownerId: owner.id_social)));
        },
        child: Stack(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 0, right: 16),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: new BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              // userList[index]
                              //     .avatar
                              (owner.avatar != '')
                                  ? owner.avatar
                                  : 'https://i.imgur.com/RUgPziD.jpg'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    owner.fullName,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
