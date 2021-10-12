import 'package:ambulancesailor/components/models/Broadcast.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Dio dio = Dio(BaseOptions(
    baseUrl: 'https://morning-journey-99210.herokuapp.com',
    connectTimeout: 60000,
    sendTimeout: 60000));

void myToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
      fontSize: 16.0);
}

void broadcasttoambulance(Broadcast broadcast) async {
  Response response = await dio.post('/', data: broadcast);

  if (response.statusCode == 200) {
    myToast("Sucess fully broad casted");
  } else {
    myToast("Not able to broadcast");
  }
}
