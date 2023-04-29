import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:gamestation/models/user_social.dart';
import 'package:gamestation/screens/dashboard/postVideoWidget.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class atCreateReelScreen extends StatefulWidget {
  String uid;

  atCreateReelScreen(required, {Key? key, required this.uid}) : super(key: key);

  @override
  _atCreateReelScreen createState() => _atCreateReelScreen(uid);
}

class _atCreateReelScreen extends State<atCreateReelScreen>
    with SingleTickerProviderStateMixin {
  String uid = '';
  _atCreateReelScreen(uid);
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
      type: FileType.video,
      allowCompression: false,
    );
    print('result');
    print(result);
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
            await FirebaseStorage.instance.ref().child('uploads/$fileName');

        link = (await ref_2.getDownloadURL()).toString();

        print(result.files.first.path.toString());
        if (result.files.first.name.contains('.mp4')) {
          setState(() {
            urlVideo = link;
            urlImage = '';
          });
        } else {
          setState(() {
            urlVideo = '';
            urlImage = link;
          });
        }
      }
    }
  }

  selectImage(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Choose Resource",
              style: TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Photo with Camera",
                  style: TextStyle(
                      fontFamily: 'Recoleta',
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
                      fontFamily: 'Recoleta',
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
                      fontFamily: 'Recoleta',
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
    FirebaseFirestore.instance.collection('reels').add({
      'userId': uid,
      'caption': captionController.text,
      'urlVideo': urlVideo,
      'ownerAvatar': user.avatar,
      'ownerUsername': user.fullName,
      'mode': 'public',
      'state': 'show',
      'likes': FieldValue.arrayUnion([]),
      'timeCreate': DateFormat('yMMMMd').format(timeCreate).toString()
    }).then((value) {
      FirebaseFirestore.instance
          .collection('reels')
          .doc(value.id)
          .update({'id': value.id});
    });
    await Future.delayed(Duration(seconds: 3)).then((value) {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    uid = userid!;
    getUserDetail();
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
            decoration: BoxDecoration(
              color: Colors.white,
            ),
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
                                post();
                              },
                              child: Icon(BootstrapIcons.plus_circle, size: 28),
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
                              'Making Your Watch',
                              style: TextStyle(
                                  fontFamily: 'Recoleta',
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
                                                    size: 30,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    selectImage(context)),
                                          ),
                                        )
                                      : postVideoWidget(context, src: urlVideo))
                                  : Container(
                                      width: 360,
                                      height: 340,
                                      padding:
                                          EdgeInsets.only(top: 24, bottom: 16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          urlImage,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                            ],
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
                                  validator: (email) {},
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
