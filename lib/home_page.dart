import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => username = prefs.getString("loginUser") ?? "");
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogin", false);
    Navigator.pushReplacementNamed(context, '/');
  }

  menu(String title, String type) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListPage(menuType: type, username: username),
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello, $username")),
      body: Column(
        children: [
          menu("News", "articles"),
          menu("Blogs", "blogs"),
          menu("Reports", "reports"),
        ],
      ),
    );
  }
}
