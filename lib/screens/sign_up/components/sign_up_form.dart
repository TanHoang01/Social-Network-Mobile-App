import 'package:flutter/material.dart';
import 'package:gamestation/components/custom_surfix_icon.dart';
import 'package:gamestation/components/default_buttom.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/dashboard/dashboard.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_auth/email_auth.dart';
import 'package:email_otp/email_otp.dart';

import '../../navigation_social/navigationBar.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;
  EmailOTP myauth = EmailOTP();

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final fullNameEditingController = new TextEditingController();
  final phoneNumberEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final otpEditingController = new TextEditingController();
  final addressEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final fullNameField = TextFormField(
        autofocus: false,
        controller: fullNameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Full Name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          fullNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Full Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final phoneNumberField = TextFormField(
        autofocus: false,
        controller: phoneNumberEditingController,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Phone Number cannot be Empty");
          }
          return null;
        },
        onSaved: (value) {
          fullNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Phone Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final addressField = TextFormField(
        autofocus: false,
        controller: addressEditingController,
        keyboardType: TextInputType.streetAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Address cannot be Empty");
          }
          return null;
        },
        onSaved: (value) {
          fullNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_city_outlined),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Address",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          // reg expression for email validation
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          fullNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          suffixIcon: GestureDetector(
            onTap: () async {
              //sendOTP();
              myauth.setConfig(
                  appEmail: "manhtan12327@gmail.com",
                  appName: "Social App OTP",
                  userEmail: emailEditingController.text,
                  otpLength: 6,
                  otpType: OTPType.digitsOnly);

              if (await myauth.sendOTP() == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("OTP has been sent to your email"),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Oops, OTP send failed"),
                ));
              }
            },
            child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text('Send OTP')),
          ),
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final otpNumberField = TextFormField(
        autofocus: false,
        controller: otpEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return ("OTP cannot be Empty");
          }
          return null;
        },
        onSaved: (value) {
          fullNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.verified_outlined),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "OTP",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)");
          }
        },
        onSaved: (value) {
          fullNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //confirm password field
    final confirmPasswordField = TextFormField(
        autofocus: false,
        controller: confirmPasswordEditingController,
        obscureText: true,
        validator: (value) {
          if (confirmPasswordEditingController.text !=
              passwordEditingController.text) {
            return "Password don't match";
          }
          return null;
        },
        onSaved: (value) {
          confirmPasswordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //signup button
    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: primaryColor,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            signUp(emailEditingController.text, passwordEditingController.text);
          },
          child: Text(
            "SignUp",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 30),
          fullNameField,
          SizedBox(height: 20),
          phoneNumberField,
          SizedBox(height: 20),
          emailField,
          SizedBox(height: 20),
          otpNumberField,
          SizedBox(height: 20),
          addressField,
          SizedBox(height: 20),
          passwordField,
          SizedBox(height: 20),
          confirmPasswordField,
          SizedBox(height: 20),
          signUpButton,
          SizedBox(height: 5),
        ],
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate() &&
        await myauth.verifyOTP(otp: otpEditingController.text) == true) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) {
          final uid = value.user?.uid;
          if (uid != null) {
            FirebaseFirestore.instance.collection("users").doc(uid).set({
              'avatar': 'https://i.imgur.com/ddLKP53.png',
              'email': emailEditingController.text,
              'favoriteList': FieldValue.arrayUnion([]),
              'follow': FieldValue.arrayUnion([]),
              'fullName': fullNameEditingController.text,
              'id_social': uid,
              'saveList': FieldValue.arrayUnion([]),
            }).then((value2) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => navigationBar(required, uid: uid)));
            });
          }
        }).catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    // writing all the values

    // FirebaseFirestore.instance.collection("messages").add({
    //   'userId1': user.uid,
    //   'userId2': 'dPG6y5dm3xZ0e4eyfqeJ7q47bKK2',
    //   'name1': fullNameEditingController.text,
    //   'name2': "Admin",
    //   'contentList': FieldValue.arrayUnion([""]),
    //   'lastTimeSend': "${DateFormat('hh:mm a').format(DateTime.now())}",
    //   'lastMessage': '',
    // }).then((value) {
    //   setState(() {
    //     FirebaseFirestore.instance
    //         .collection("messages")
    //         .doc(value.id)
    //         .update({
    //       'messageId': value.id,
    //     });
    //     firebaseFirestore.collection("users").doc(user.uid).update({
    //       'messageId': value.id,
    //     });
    //   });
    // });

    Navigator.pushAndRemoveUntil((context),
        MaterialPageRoute(builder: (context) => DashBoard()), (route) => false);
  }
  // void sendOTP() async {
  //   var res = await EmailAuth(sessionName: "GameStation").sendOtp(recipientMail: emailEditingController.text);
  //   if(res){
  //     Fluttertoast.showToast(msg: "Please check your email for OTP code ");
  //   }else{
  //     Fluttertoast.showToast(msg: "We could not send OTP to your email");
  //   }
  // }

  // bool verifyOTP() {
  //   var res = EmailAuth(sessionName: "Verify OTP").validateOtp(recipientMail: emailEditingController.text, userOtp: otpEditingController.text);
  //   if(res){
  //     return true;
  //   }else{
  //     Fluttertoast.showToast(msg: "Please enter valid OTP code ");
  //     return false;
  //   }
  // }
}
