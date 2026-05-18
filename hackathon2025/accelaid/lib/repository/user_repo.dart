import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class UserRepo {
   final CollectionReference usersRef;

  UserRepo({required this.usersRef});

  /// initializes users in firebase if its empty, else use it


  /// sign up a new user account
  Future<User?> signUp(
      {required String email,
      required String password,
      required String fullName}) async {
    User? user;

    try {
      final authUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = authUser.user;
      await user?.updateDisplayName(fullName).then((fn) {
        user?.reload();
      });

      final docRef = usersRef.doc(email);
      var firstName = fullName.split(' ');
      var lastName = firstName.removeLast();
      await docRef.set({
        'email': email,
        'firstName': firstName.join(' ').trim(),
        'lastName': lastName
      });

      print('User Sign-Up Sucess: [${authUser.user?.uid}]');
    } catch (e) {
      print('User Sign-Up Failed: $e');
    }
    return FirebaseAuth.instance.currentUser;
  }

  /// sign in user
  Future<User?> signIn(
      {required String email, required String password}) async {
    try {
      final authUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User Sign-In Sucess: ${authUser.user?.displayName}');
      return authUser.user;
    } catch (e) {
      print('User Sign-In Failed: $e');
    }
    return null;
  }

  /// sign out
  Future<void> signOut() async => await FirebaseAuth.instance.signOut();

  /// get current logged in user
  Future<User?> getCurrentUser() async => FirebaseAuth.instance.currentUser;
}
