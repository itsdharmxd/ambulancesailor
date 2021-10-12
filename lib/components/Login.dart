import 'package:ambulancesailor/components/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controller = TextEditingController();
  String ambulaceno = '', drivername = '';

  submit() async {
    print(ambulaceno + " " + drivername);
    bool c = false;
    await CoolAlert.show(
        widget: Text("No :${this.ambulaceno}\nName :${this.drivername}"),
        context: context,
        type: CoolAlertType.confirm,
        onConfirmBtnTap: () {
          c = true;
          Navigator.pop(context);
        });
    print(1);
    if (!c) return;
    print(1);
    Provider.of<UserProvider>(context, listen: false)
        .setambulanceno(ambulaceno);
    Provider.of<UserProvider>(context, listen: false).setdrivername(drivername);
    print(1);
    Navigator.pushNamed(context, '/map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credentials'),
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            TextFormField(
              onChanged: (String s) {
                this.ambulaceno = s;
              },
              maxLength: 20,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.red,
                ),
                labelText: 'Ambulace no',
                labelStyle: TextStyle(
                  color: Colors.teal,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            TextFormField(
              onChanged: (String s) {
                this.drivername = s;
              },
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                labelText: 'Driver name',
                labelStyle: TextStyle(
                  color: Colors.teal,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
           
              TextFormField(
              onChanged: (String s) {
                this.ambulaceno = s;
              },
              maxLength: 20,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.mobile_friendly_rounded,
                  color: Colors.red,
                ),
                labelText: 'Mobile no',
                labelStyle: TextStyle(
                  color: Colors.teal,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                
                onPressed: submit,
                child: Text("SUBMIT"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
