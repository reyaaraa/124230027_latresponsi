import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", usernameCtrl.text);
    prefs.setString("password", passwordCtrl.text);

    Navigator.pop(context);
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            ElevatedButton(onPressed: save, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
