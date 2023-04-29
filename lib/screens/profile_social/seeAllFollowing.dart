import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/profile_social/profile.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class seeAllFollowing extends StatefulWidget {
  late List idUser;
  seeAllFollowing({Key? key, required this.idUser}) : super(key: key);
  @override
  _seeAllFollowing createState() => _seeAllFollowing(this.idUser);
}

class _seeAllFollowing extends State<seeAllFollowing> {
  List<userModel> userSearch = [];
  List<userModel> userList = [];
  List idUser = [];

  _seeAllFollowing(this.idUser);
  Future searchName() async {
    FirebaseFirestore.instance.collection("users").snapshots().listen((value) {
      setState(() {
        userSearch.clear();
        userList.clear();
        value.docs.forEach((element) {
          userSearch.add(userModel.fromDocument(element.data()));
        });
        idUser.forEach((element1) {
          userSearch.forEach((element2) {
            if (element1 == element2.id_social) {
              userList.add(element2);
            }
          });
        });
      });
    });
  }

  @override
  void initState() {
    searchName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent),
      child: SafeArea(
          child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(BootstrapIcons.caret_left_fill, size: 28),
                      ),
                      Spacer(),
                      Container()
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All Following',
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
                                                      ownerId: userList[index]
                                                          .id_social,
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
          ],
        ),
      )),
    );
  }
}
