import 'package:ambulancesailor/components/Login.dart';
import 'package:ambulancesailor/components/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MyMap.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(create: (_)=>UserProvider(),
      child: MaterialApp(
        theme: ThemeData(primaryColor: Colors.teal),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/map': (BuildContext context) {
            return MyMap();
          },
          '/login': (BuildContext context) {
            return Login();
          }
        },
      ),
    );
  }
}
