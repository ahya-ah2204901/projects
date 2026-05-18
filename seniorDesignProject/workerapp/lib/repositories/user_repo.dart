import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:workerapp/models/alert.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/user.dart';
//import 'package:yala_pay/models/cheque.dart';
//import 'package:yala_pay/repositories/image_repo.dart';

import 'package:firebase_auth/firebase_auth.dart' hide User;

class UserRepo {
  final CollectionReference userRef;

  UserRepo({required this.userRef});

  /// reads from user json file
  Future<void> initializeUsers() async {
    if (userRef == null) {
      print('Error: userRef is null');
      return;
    }

    final snapshot = await userRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/users.json');
        var userJsonList = jsonDecode(data);
        for (var userMap in userJsonList) {
          User user = User.fromMap(userMap);
          //String? uri = await uploadImageFromAssets(cheque.chequeImageUri);
          //final docRef = userRef.doc(cheque.chequeNo.toString());
          final newUser = User(
            id: user.id,
            email: user.email,
            //password: user.password,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            supervisorId: user.supervisorId ?? null,
          );
          await userRef.doc(user.id.toString()).set(newUser.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing user: $e');
      }
    }
  }

  /// sign up a new user account
  Future<fb.User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? supervisorId,
  }) async {
    fb.User? user;
    String fullName = "$firstName $lastName";
    try {
      final authUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      user = authUser.user;

      await user?.sendEmailVerification();
      await user?.updateDisplayName(fullName).then((fn) {
        user?.reload();
      });

      final docRef = userRef.doc(user!.uid);
      await docRef.set({
        'id': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'supervisorId': supervisorId,
      });

      print('User Sign-Up Sucess: [${user.uid}]');
    } catch (e) {
      print('User Sign-Up Failed: $e');
    }
    return FirebaseAuth.instance.currentUser;
  }

  /// sign in user
  Future<fb.User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await authUser.user?.reload();
      final user = FirebaseAuth.instance.currentUser;

      // if (user != null && !user.emailVerified) {
      //   await FirebaseAuth.instance.signOut();
      //   throw Exception('Please verify your email before logging in.');
      // }
      print('User Sign-In Sucess: ${authUser.user?.displayName}');
      return authUser.user;
    } catch (e) {
      print('User Sign-In Failed: $e');
    }
    return null;
  }

  Future<void> resetPassword({required String email}) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> refreshEmailVerificationStatus() async {
    await FirebaseAuth.instance.currentUser?.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  // sign out
  Future<void> signOut() async => await FirebaseAuth.instance.signOut();

  /// get current logged in user
  Future<fb.User?> getCurrentUser() async => FirebaseAuth.instance.currentUser;

  /// get current logged in user as user object
  //Future<fb.User?> getCurrentUserObject() async => FirebaseAuth.instance.currentUser.uid;

  /// get current logged in user
  Future<String?> getCurrentUserId() async =>
      FirebaseAuth.instance.currentUser?.uid;

  Future<void> saveFcmToken(String userId, String token) async {
    await userRef.doc(userId).set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<String?> getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    return FirebaseMessaging.instance.getToken();
  }

  Stream<String> onFcmTokenRefresh() {
    return FirebaseMessaging.instance.onTokenRefresh;
  }

  Future<void> initNotifications() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground message:");
      print(message.notification?.title);
      print(message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("User tapped notification");
      print(message.data);
    });
  }

  Stream<Map<String, dynamic>?> observeLatestPrediction(String workerId) {
    return userRef
        .doc(workerId)
        .collection('latest_prediction')
        .doc('current')
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>?);
  }

  /// observe all users
  Stream<List<User>> observeUsers() {
    return userRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  Stream<List<User>> getWorkersForSupervisor(String supervisorId) {
    return observeUsers().map((allUsers) {
      return allUsers.where((u) => u.supervisorId == supervisorId).toList();
    });
  }

  Future<User> getUserFromEmail(String email) async {
    final snapshot = await userRef.get();
    final users = snapshot.docs.map((doc) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return users.firstWhere(
      (u) => u.email == email,
      orElse: () {
        throw Exception('User not found');
      },
    );
  }

  Future<bool> isExistingUser(String email) async {
    final snapshot = await userRef
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<User?> getUserByEmail(String email) async {
    final snapshot = await userRef
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return User.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  Future<User?> getSupervisorByEmail(String email) async {
    final snapshot = await userRef
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'Supervisor')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return User.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }
}
