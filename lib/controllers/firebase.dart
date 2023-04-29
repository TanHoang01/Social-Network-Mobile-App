import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamestation/screens/dashboard/dashboard.dart';
import 'package:gamestation/screens/sign_in/sign_in_screen.dart';

FirebaseAuth auth = FirebaseAuth.instance;
signOut(context) async {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => SignInScreen()));
  await _firebaseAuth.signOut();
}

Future sign_up(String email, String password, context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      final User? user = _auth.currentUser;
      final uid = user?.uid;
      FirebaseFirestore.instance.collection('users').add({
        'fullName': '',
        'userName': '',
        'phonenumber': '',
        'email': email,
        "userId": uid,
        'state': 'online',
        'avatar': "https://i.imgur.com/YtZkAbe.jpg",
        'background': 'https://i.imgur.com/fRjRPRc.jpg',
        'favoriteList': FieldValue.arrayUnion([]),
        'saveList': FieldValue.arrayUnion([]),
        'follow': FieldValue.arrayUnion([]),
      }).then((signedInUser) => {
            signIn(email, password, context),
            print("successfully registered!"),
          });
    });
  } on FirebaseAuthException catch (e) {
    print(e.code);
    switch (e.code) {
      case "operation-not-allowed":
        const SnackBar(
          content: Text('Anonymous accounts are not enabled!'),
        );
        break;
      case "weak-password":
        const SnackBar(content: Text("Your password is too weak!"));
        break;
      case "invalid-email":
        const SnackBar(
            content: Text("Your email is invalid, please try again!"));
        break;
      case "email-already-in-use":
        const SnackBar(content: Text("Email is used on different account!"));
        break;
      case "invalid-credential":
        const SnackBar(
            content: Text("Your email is invalid, please try again!"));
        break;

      default:
        const SnackBar(content: Text("An undefined Error happened!"));
    }
  }
}

Future signIn(String email, String password, context) async {
  try {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      print("successfully login!");
      final User? user = auth.currentUser;
      final uid = user?.uid;
      // print("Your current id is $uid");
      if (uid != null) {
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DashBoard()));
      }
    });
  } on FirebaseAuthException catch (e) {
    print(e.code);
    switch (e.code) {
      // case "user-not-found":
      //   showSnackBar(
      //       context, "Your email is not found, please check!", 'error');
      //   break;
      // case "wrong-password":
      //   showSnackBar(context, "Your password is wrong, please check!", 'error');
      //   break;
      // case "invalid-email":
      //   showSnackBar(context, "Your email is invalid, please check!", 'error');
      //   break;
      // case "user-disabled":
      //   showSnackBar(context, "The user account has been disabled!", 'error');
      //   break;
      // case "too-many-requests":
      //   showSnackBar(
      //       context, "There was too many attempts to sign in!", 'error');
      //   break;
      // case "operation-not-allowed":
      //   showSnackBar(context, "The user account are not enabled!", 'error');
      //   break;
      // // Preventing user from entering email already provided by other login method
      // case "account-exists-with-different-credential":
      //   showErrorSnackBar(context, "This account exists with a different sign in provider!");
      //   break;

      // default:
      //   showSnackBar(context, "An undefined Error happened.", 'error');
    }
  }
}
