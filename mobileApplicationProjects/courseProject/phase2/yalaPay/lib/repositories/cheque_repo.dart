import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/repositories/image_repo.dart';

class ChequeRepo {
  final CollectionReference chequeRef;

  final ImageRepository _imageRepo = ImageRepository();

  ChequeRepo({required this.chequeRef});

  /// reads from cheque json file
  Future<void> initializeCheques() async {
    if (chequeRef == null) {
      print('Error: chequeRef is null');
      return;
    }

    final snapshot = await chequeRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/cheques.json');
        var chequeJsonList = jsonDecode(data);
        for (var chequeMap in chequeJsonList) {
          Cheque cheque = Cheque.fromMap(chequeMap);
          String? uri = await uploadImageFromAssets(cheque.chequeImageUri);
          //final docRef = chequeRef.doc(cheque.chequeNo.toString());
          final newCheque = Cheque(
            chequeNo: cheque.chequeNo,
            amount: cheque.amount,
            drawer: cheque.drawer,
            bankName: cheque.bankName,
            status: cheque.status,
            receivedDate: cheque.receivedDate,
            dueDate: cheque.dueDate,
            chequeImageUri: uri ?? cheque.chequeImageUri,
            returnReason: cheque.returnReason,
            returnDate: cheque.returnDate,
            cashedDate: cheque.cashedDate,
          );
          await chequeRef
              .doc(cheque.chequeNo.toString())
              .set(newCheque.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing cheque: $e');
      }
    }
  }

  /// observe all cheques
  Stream<List<Cheque>> observeCheques() {
    return chequeRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Cheque.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> updateChequeStatus(Cheque cheque, String chequeStatus) async {
    final updatedCheque = Cheque(
        chequeNo: cheque.chequeNo,
        amount: cheque.amount,
        drawer: cheque.drawer,
        bankName: cheque.bankName,
        status: chequeStatus, //used for deleting and adding cheque deposit
        receivedDate: cheque.receivedDate,
        dueDate: cheque.dueDate,
        chequeImageUri: cheque.chequeImageUri,
        returnReason: null,
        returnDate: null,
        cashedDate: null);

    await chequeRef
        .doc(updatedCheque.chequeNo.toString())
        .update(updatedCheque.toMap());
  }

  Stream<List<Cheque>> getAwaitingCheques() {
    return chequeRef
        .where('status', whereIn: ['Awaiting', 'awaiting'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheque.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<Cheque> findCheque(int chequeNo) async {
    final snapshot = await chequeRef.get();
    final cheques = snapshot.docs.map((doc) {
      return Cheque.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return cheques.firstWhere((c) => c.chequeNo == chequeNo, orElse: () {
      throw Exception('Cheque not found');
    });
  }

  Future<double> getTotalChequeAmount(List<dynamic> chequeNos) async {
    double total = 0;

    List<int> validChequeNos = [];
    for (var chequeNo in chequeNos) {
      final parsedChequeNo = int.tryParse(chequeNo.toString());

      if (parsedChequeNo != null) {
        validChequeNos.add(parsedChequeNo);
      } else {
        //print("Invalid cheque number: $chequeNo");
      }
    }

    if (validChequeNos.isEmpty) {
      //print("No valid cheque numbers provided.");
      return total;
    }

    try {
      final snapshot =
          await chequeRef.where('chequeNo', whereIn: validChequeNos).get();

      // print("Number of documents fetched: ${snapshot.docs.length}");

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final amount = data['amount'];

        double amountParsed = 0.0;
        if (amount is String) {
          amountParsed = double.tryParse(amount) ?? 0.0;
        } else if (amount is num) {
          amountParsed = amount.toDouble();
        }

        //print("Cheque No: ${data['chequeNo']}, Amount: $amountParsed");
        total += amountParsed;
      }
    } catch (e) {
      print("Error fetching cheques: $e");
    }

    return total;
  }

  Future<void> updateChequeCashed(
      Cheque cheque, String chequeStatus, String cashedDate) async {
    final updatedCheque = Cheque(
        chequeNo: cheque.chequeNo,
        amount: cheque.amount,
        drawer: cheque.drawer,
        bankName: cheque.bankName,
        status: chequeStatus, //used for updating cheque
        receivedDate: cheque.receivedDate,
        dueDate: cheque.dueDate,
        chequeImageUri: cheque.chequeImageUri,
        returnReason: null,
        returnDate: null,
        cashedDate: DateTime.tryParse(cashedDate) ??
            cheque.cashedDate //used for updating cheque
        );
    await chequeRef
        .doc(updatedCheque.chequeNo.toString())
        .update(updatedCheque.toMap());
  }

  Future<void> updateChequeReturn(Cheque cheque, String chequeStatus,
      String returnReason, String returnDate) async {
    final updatedCheque = Cheque(
        chequeNo: cheque.chequeNo,
        amount: cheque.amount,
        drawer: cheque.drawer,
        bankName: cheque.bankName,
        status: chequeStatus, //used for updating cheque
        receivedDate: cheque.receivedDate,
        dueDate: cheque.dueDate,
        chequeImageUri: cheque.chequeImageUri,
        returnReason: returnReason,
        returnDate: DateTime.tryParse(returnDate) ?? cheque.returnDate,
        cashedDate: null //used for updating cheque
        );
    await chequeRef
        .doc(updatedCheque.chequeNo.toString())
        .update(updatedCheque.toMap());
  }

  /// returns queried cheques
  Future<List<Cheque>> filterCheques(
      String startDate, String endDate, String status) async {
    List<Cheque> filteredCheques = [];
    await chequeRef
        .where("dueDate", isLessThanOrEqualTo: endDate)
        .where("dueDate", isGreaterThanOrEqualTo: startDate)
        .get()
        .then((snapshot) {
      filteredCheques = snapshot.docs
          .map((doc) {
            return Cheque.fromMap(doc.data() as Map<String, dynamic>);
          })
          .where((cheque) => (status == 'All') ? true : cheque.status == status)
          .toList();
    });

    // if status is all, no need to filter status
    return filteredCheques;
  }

  Future<List<double>> totalChequesOfAllStatuses(List<String> statuses) async {
    List<double> total = [0.0, 0.0, 0.0, 0.0];
    int index = 0;
    for (String status in statuses) {
      final snapshot = await chequeRef.where('status', isEqualTo: status).get();
      final returnedCheques = snapshot.docs;

      for (final data in returnedCheques) {
        total[index] += (data['amount'] ?? 0).toDouble();
      }
      index++;
    }

    return total;
  }


  Future<void> addChequeAsPayment(
      int chequeNo,
      double amount,
      String drawer,
      String bank,
      DateTime receivedDate,
      DateTime dueDate,
      String imageURL) async {
    final newCheque = Cheque(
        chequeNo: chequeNo,
        amount: amount,
        drawer: drawer,
        bankName: bank,
        status: "Awaiting",
        receivedDate: receivedDate,
        dueDate: dueDate,
        chequeImageUri: imageURL);

    await chequeRef.doc(newCheque.chequeNo.toString()).set(newCheque.toMap());
  }

  Future<void> deleteCheque(Cheque cheque) async {
    try{
    final storageRef = FirebaseStorage.instance.ref();
    await storageRef.child("images/${cheque.chequeImageUri}").delete();
    } catch (e) {
        print('Error deleteing asset image for cheque: $e');
    }
    //deletes cheque in collections
    await chequeRef.doc(cheque.chequeNo.toString()).delete();
  }

  //images!!

  Future<String?> uploadImageFromAssets(String? imageUri) async {
    if (imageUri != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref();

        final byteData =
            await rootBundle.load('assets/images/cheques/$imageUri');

        final fileBytes = byteData.buffer.asUint8List();

        final file = File('${(Directory.systemTemp.path)}/$imageUri')
          ..writeAsBytesSync(fileBytes);

        final fileName = 'cheque_${DateTime.now().millisecondsSinceEpoch}';
        final uploadTask = await storageRef
            .child("images/$fileName")
            .putFile(file);

        final imageUrl = await uploadTask.ref.getDownloadURL();

        return fileName;
      } catch (e) {
        print('Error uploading asset image for cheque: $e');
        return null;
      }
    }
    return null;
  }

  Future<String?> uploadChequeImageFromGallery() async {
    try {
      final imageFile = await _imageRepo.pickImageFromGallery();
      if (imageFile == null) {
        print('No image selected.');
        return null;
      }

      final downloadUrl = await _imageRepo.uploadImage(imageFile, 'images');
      if (downloadUrl == null) {
        print('Failed to upload image.');
        return null;
      }
      print( 'downloadUrl $downloadUrl');
      return downloadUrl;
      

    } catch (e) {
      print('Error uploading gallery image for cheque: $e');
      return null;
    }
  }

  Future<String?> uploadChequeImageFromCamera() async {
    try {
      final imageFile = await _imageRepo.pickImageFromCamera();
      if (imageFile == null) {
        print('No image captured.');
        return null;
      }

      final downloadUrl = await _imageRepo.uploadImage(imageFile, 'images');

      if (downloadUrl == null) {
        print('Failed to upload image.');
        return null;
      }
  
      return downloadUrl;
    } catch (e) {
      print('Error uploading camera image for cheque: $e');
      return null;
    }
  }
}
