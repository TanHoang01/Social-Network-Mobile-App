import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/dashboard/postVideoWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tflite/tflite.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class atCreatePostScreen extends StatefulWidget {
  String uid;

  atCreatePostScreen(required, {Key? key, required this.uid}) : super(key: key);

  @override
  _atCreatePostScreen createState() => _atCreatePostScreen(uid);
}

class _atCreatePostScreen extends State<atCreatePostScreen>
    with SingleTickerProviderStateMixin {
  String uid = '';
  _atCreatePostScreen(uid);
  File? imageFile;
  File? videoFile;
  String link = '';

  TextEditingController captionController = TextEditingController();
  final GlobalKey<FormState> captionFormKey = GlobalKey<FormState>();

  handleTakePhoto() async {
    Navigator.pop(context);
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  late String urlImage = '';
  late String urlVideo = '';

  Future handleTakeGallery() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      // Upload file
      print(result.files.first.name);
      print(result.files.first.path);
      if (result.files.first.path != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref('uploads/$fileName');
        UploadTask uploadTask =
            ref.putFile(File(result.files.first.path.toString()));
        Reference ref_2 =
            FirebaseStorage.instance.ref().child('uploads/$fileName');

        link = (await ref_2.getDownloadURL()).toString();

        print(result.files.first.path.toString());
        if (result.files.first.name.contains('.mp4')) {
          setState(() {
            urlVideo = link;
            urlImage = '';
            _results = [];
            checked = true;
          });
        } else {
          final List? recognitions = await Tflite.runModelOnImage(
            path: result.files.first.path.toString(),
            numResults: 1,
            threshold: 0.05,
            imageMean: 127.5,
            imageStd: 127.5,
          );
          setState(() {
            urlVideo = '';
            urlImage = link;
            _results = recognitions!;
            recognitions.forEach((element) {
              if (element['label'] == 'cleaver' ||
                  element['label'] == 'rifle') {
                setState(() {
                  checked = false;
                });
              } else {
                setState(() {
                  checked = true;
                });
              }
              if (checked == true) {
                const snackBar =
                    SnackBar(content: Text("Your image is available"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                const snackBar = SnackBar(
                    content: Text(
                        "You should not post photos that violate community standards! Button post is disable"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            });
          });
        }
        print(checked);
      }
    }
  }

  List _results = [];
  bool checked = false;

  selectImage(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Choose Resource",
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Photo with Camera",
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text(
                  "Photo with Gallery",
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                onPressed: handleTakeGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  List userFollower = [];
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

  late DateTime timeCreate = DateTime.now();
  Future post() async {
    FirebaseFirestore.instance.collection('posts').add({
      'userId': uid,
      'caption': captionController.text,
      'urlImage': urlImage,
      'urlVideo': urlVideo,
      'ownerAvatar': user.avatar,
      'ownerUsername': user.fullName,
      'mode': 'public',
      'state': 'show',
      'likes': FieldValue.arrayUnion([]),
      'timeCreate': "${DateFormat('y MMMM d, hh:mm:ss').format(DateTime.now())}"
    }).then((value) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(value.id)
          .update({'id': value.id});
    });
    Navigator.pop(context);
  }

  String resultError = '';
  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
            model: "assets/model.tflite", labels: "assets/labels.txt")
        .onError((error, stackTrace) {
      resultError = 'PLease choose another image';
      return null;
    }))!;
    print("Models loading status: $res");
  }

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    uid = userid!;
    getUserDetail();
    loadModel();
  }

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
            decoration: BoxDecoration(color: Colors.white),
          ),
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Container(
                      margin:
                          EdgeInsets.only(left: 24, right: 24, top: 20 + 20),
                      child: Column(children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(BootstrapIcons.caret_left_fill,
                                  size: 28),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                if (checked == true) {
                                  post();
                                } else {
                                  const SnackBar(
                                    content: Text('Button post is disable'),
                                  );
                                }
                              },
                              child: Icon(
                                checked == false
                                    ? BootstrapIcons.exclamation_triangle
                                    : BootstrapIcons.shield_check,
                                size: 28,
                                color: (checked == false)
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 24),
                        Container(
                            // margin: EdgeInsets.only(
                            //     left: 24, right: 24, top: 20 + 20),
                            child: Column(children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Making Your Post',
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 192,
                              height: 0.5,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 144,
                              height: 0.5,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              (urlImage == '')
                                  ? ((urlVideo == '')
                                      ? Container(
                                          padding: EdgeInsets.all(24),
                                          alignment: Alignment.center,
                                          child: Container(
                                            child: IconButton(
                                                icon: Icon(
                                                    BootstrapIcons
                                                        .plus_square_dotted,
                                                    size: 50,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    selectImage(context)),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            postVideoWidget(context,
                                                src: urlVideo),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            GestureDetector(
                                                onTap: () =>
                                                    selectImage(context),
                                                child: Center(
                                                    child: Text('Video Post')))
                                          ],
                                        ))
                                  : GestureDetector(
                                      onTap: () => selectImage(context),
                                      child: Container(
                                        width: 360,
                                        height: 340,
                                        padding: EdgeInsets.only(
                                            top: 24, bottom: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            urlImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                          (_results.isEmpty)
                              ? Container()
                              : SingleChildScrollView(
                                  child: Column(
                                    children: _results.map((result) {
                                      setState(() {});
                                      return Card(
                                        child: Container(
                                          margin: EdgeInsets.all(10),
                                          child: Text("${result['label']} ",
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                          SizedBox(height: 16),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Caption: ',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Form(
                            key: captionFormKey,
                            child: Container(
                              width: 327 + 24,
                              margin: EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.topCenter,
                              child: TextFormField(
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  //validator
                                  validator: (email) {
                                    // if (isEmailValid(email.toString())) {
                                    //   WidgetsBinding.instance!
                                    //       .addPostFrameCallback((_) {
                                    //     setState(() {
                                    //       notiColorEmail = green;
                                    //     });
                                    //   });
                                    //   return null;
                                    // } else {
                                    //   WidgetsBinding.instance!
                                    //       .addPostFrameCallback((_) {
                                    //     setState(() {
                                    //       notiColorEmail = red;
                                    //     });
                                    //   });
                                    //   return '';
                                    // }
                                  },
                                  controller: captionController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    hintStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black.withOpacity(0.5)),
                                    hintText: "Write something about your post",
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorStyle: TextStyle(
                                      color: Colors.transparent,
                                      fontSize: 0,
                                      height: 0,
                                    ),
                                  )),
                            ),
                          ),
                        ]))
                      ]))))
        ])));
  }
}
