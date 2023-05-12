import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> getProfilePicture(String uid) async {
    String imageUrl = 'profile-pic/' + uid + '.png';
    String error = "";
    String downloadURL = "";
    try {
      await storage.ref(imageUrl).getDownloadURL();
    } on firebase_storage.FirebaseException catch (myError) {
      switch (myError.code) {
        case 'object-not-found':
          error = myError.toString();
      }
    }

    if (error == "") {
      downloadURL = await storage.ref(imageUrl).getDownloadURL();
    } else {
      downloadURL =
          await storage.ref("profile-pic/profile.png").getDownloadURL();
    }

    return downloadURL;
  }

  Future<String> getTournamentPicture(String id) async {
    String imageUrl = 'tournament-pic/' + id + '.png';
    String error = "";
    String downloadURL = "";
    try {
      await storage.ref(imageUrl).getDownloadURL();
    } on firebase_storage.FirebaseException catch (myError) {
      switch (myError.code) {
        case 'object-not-found':
          error = myError.toString();
      }
    }

    if (error == "") {
      downloadURL = await storage.ref(imageUrl).getDownloadURL();
    } else {
      downloadURL =
          await storage.ref("profile-pic/tournament.png").getDownloadURL();
    }

    return downloadURL;
  }

  Future<String> getTournamentPromo(String id) async {
    String imageUrl = 'tournament-promo/' + id + '.mp4';
    String error = "";
    String downloadURL = "";
    try {
      await storage.ref(imageUrl).getDownloadURL();
    } on firebase_storage.FirebaseException catch (myError) {
      switch (myError.code) {
        case 'object-not-found':
          error = myError.toString();
      }
    }

    if (error == "") {
      downloadURL = await storage.ref(imageUrl).getDownloadURL();
    } else {
      downloadURL = "error";
    }

    return downloadURL;
  }
}
