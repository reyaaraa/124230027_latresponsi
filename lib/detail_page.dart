import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final int id;
  final String type;

  const DetailPage({super.key, required this.id, required this.type});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ApiService api = ApiService();
  Map detail = {};

  loadDetail() async {
    detail = await api.fetchDetail(widget.type, widget.id);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Text(detail['title'] ?? "")),
      body: detail.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Text(detail['summary'] ?? "-"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => launchUrl(Uri.parse(detail['url'])),
        child: const Icon(Icons.open_in_browser),
      ),
    );
  }
}
