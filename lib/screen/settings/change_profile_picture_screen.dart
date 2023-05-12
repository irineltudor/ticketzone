import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticketzone/model/user.dart';
import 'package:ticketzone/screen/settings/settings_screen.dart';
import 'package:ticketzone/service/storage_service.dart';

class ChangeProfilePictureScreen extends StatefulWidget {
  const ChangeProfilePictureScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<ChangeProfilePictureScreen> {
  File? _profilePicture;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      print("im here?");
      super.setState(fn);
    }
  }

  Future<void> getData() async {
    FirebaseFirestore.instance
        .collection("user")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (await Permission.mediaLibrary.isDenied) {
      Permission.mediaLibrary.request();
    }

    if (await Permission.mediaLibrary.isGranted) {
      XFile? selected = await ImagePicker().pickImage(source: source);
      if (selected != null) {
        CroppedFile? cropped = await ImageCropper().cropImage(
          sourcePath: selected.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.png,
        );
        setState(() {
          if (cropped != null) {
            _profilePicture = File(cropped!.path);
          }
        });
      }
    }
  }

  void _clear() {
    setState(() => _profilePicture = null);
  }

  Future<void> _cropImage() async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: _profilePicture!.path,
        compressFormat: ImageCompressFormat.png);

    setState(() {
      _profilePicture =
          croppedImage != null ? File(croppedImage.path) : _profilePicture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final photoButton = Material(
        elevation: 5,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_library,
                  color: Colors.black, size: 30),
              onPressed: () => _pickImage(
                ImageSource.gallery,
              ),
            )
          ],
        ));

    if (loggedInUser.dob == null) {
      return Container(
          color: Colors.black,
          child: const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          )));
    } else {
      return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: const Text('Change Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit-Regular',
                )),
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            child: photoButton,
          ),
          body: Stack(
            children: [
              Positioned(
                top: height * 0.02,
                height: height * 0.815,
                left: height * 0.005,
                right: height * 0.005,
                child: ClipRRect(
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(45)),
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        children: [
                          if (_profilePicture == null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: height * 0.4,
                                ),
                                Text(
                                  "*Select a picture from gallery",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          if (_profilePicture != null) ...[
                            Image.file(
                              _profilePicture!,
                              fit: BoxFit.cover,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: _cropImage,
                                    child: const Icon(Icons.crop,
                                        color: Colors.black)),
                                TextButton(
                                    onPressed: _clear,
                                    child: const Icon(Icons.delete,
                                        color: Colors.black))
                              ],
                            ),
                            Upload(file: _profilePicture!)
                          ]
                        ],
                      ),
                    )),
              ),
            ],
          ));
    }
  }
}

class Upload extends StatefulWidget {
  final File file;

  Upload({Key? key, required this.file}) : super(key: key);

  createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final storage = firebase_storage.FirebaseStorage.instance;
  User? user = FirebaseAuth.instance.currentUser;

  firebase_storage.UploadTask? _uploadTask;

  void _startUpload() {
    String filePath = 'profile-pic/' + user!.uid + '.png';

    setState(() {
      _uploadTask = storage.ref().child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<firebase_storage.TaskSnapshot>(
          stream: _uploadTask!.snapshotEvents,
          builder: (context, snapshot) {
            var event = snapshot.data ?? null;

            double progressPercent =
                event != null ? event.bytesTransferred / event.totalBytes : 0;

            if (progressPercent == 1)
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });

            return Column(
              children: [
                if (_uploadTask!.snapshot.state ==
                    firebase_storage.TaskState.success)
                  Text('Profile Pic Changed'),
                if (_uploadTask!.snapshot.state ==
                    firebase_storage.TaskState.paused)
                  TextButton(
                      onPressed: () => _uploadTask!.resume(),
                      child: Icon(Icons.play_arrow, color: Colors.black)),
                if (_uploadTask!.snapshot.state ==
                    firebase_storage.TaskState.running)
                  TextButton(
                      onPressed: () => _uploadTask!.pause(),
                      child: Icon(Icons.pause, color: Colors.black)),
                LinearProgressIndicator(value: progressPercent),
                Text('${(progressPercent * 100).toStringAsFixed(2)}%'),
              ],
            );
          });
    } else {
      return Material(
        elevation: 10,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(20),
        child: MaterialButton(
          onPressed: _startUpload,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Set Profile Picture',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      );
    }
  }
}
