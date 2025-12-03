import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'detail_page.dart';

class ListPage extends StatefulWidget {
  final String menuType;
  final String username;

  const ListPage({super.key, required this.menuType, required this.username});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  ApiService api = ApiService();
  List data = [];

  loadData() async {
    data = await api.fetchList(widget.menuType);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.menuType} - ${widget.username}")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(data[i]['title']),
            subtitle: Text(data[i]['published_at']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailPage(id: data[i]['id'], type: widget.menuType),
              ),
            ),
          );
        },
      ),
    );
  }
}
