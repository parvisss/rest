import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class FirestoreServise {
  final firestore = FirebaseFirestore.instance;

  Future<void> addData(
    String givedName,
    Point location,
    String name,
    String phone,
    int rate,
  ) async {
    firestore.collection("restaurants").add(
      {
        "name": name,
        "location": "${location.latitude},${location.longitude}",
        "givedName": givedName,
        "phone": phone,
        "rate": rate
      },
    );
  }

  Stream<QuerySnapshot> getData() async* {
    yield* firestore.collection("restaurants").snapshots();
  }
}
