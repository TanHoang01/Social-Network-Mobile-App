import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

hidePostDialog(BuildContext mContext, String postId) {
  return showDialog(
      context: mContext,
      builder: (context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            backgroundColor: Colors.white,
            content: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 264,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      children: [
                        const Text(
                          "Do you want to delete this post?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.6),
                        ),
                        SizedBox(height: 32),
                        Container(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId)
                                    .delete();
                                Navigator.of(context).pop();
                              },
                              child: AnimatedContainer(
                                  alignment: Alignment.center,
                                  duration: Duration(milliseconds: 300),
                                  height: 54,
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 60,
                                        offset: Offset(10, 10),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  )),
                            )),
                        SizedBox(height: 16),
                        Container(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: AnimatedContainer(
                                  alignment: Alignment.center,
                                  duration: Duration(milliseconds: 300),
                                  height: 54,
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(
                                          width: 3, color: Colors.white),
                                      left: BorderSide(
                                          width: 3, color: Colors.white),
                                      right: BorderSide(
                                          width: 3, color: Colors.white),
                                      bottom: BorderSide(
                                          width: 3, color: Colors.white),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 60,
                                        offset: Offset(10, 10),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  )),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ));
      });
}
