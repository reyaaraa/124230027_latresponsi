import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final String type;
  final String id;
  const DetailPage({super.key, required this.type, required this.id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;
  bool _expanded = false; // for long summary toggle

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchDetail(widget.type, widget.id);
      setState(() {
        _detail = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openUrl(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No URL available')));
      return;
    }
    final uri = Uri.parse(urlStr);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open URL')));
    }
  }

  String _formatDate(String? s) {
    if (s == null || s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s);
      return '${dt.day} ${_month(dt.month)} ${dt.year}';
    } catch (_) {
      return s;
    }
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final image =
        _detail?['image_url'] ??
        _detail?['image'] ??
        _detail?['featured_image'] ??
        '';
    final title = _detail?['title'] ?? _detail?['name'] ?? '-';
    final source = _detail?['news_site'] ?? _detail?['source'] ?? 'Unknown';
    final date = _formatDate(
      _detail?['published_at'] ?? _detail?['publishedAt'],
    );
    final summary =
        (_detail?['summary'] ??
                _detail?['description'] ??
                _detail?['excerpt'] ??
                '')
            as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const SafeArea(child: Center(child: CircularProgressIndicator()))
          : _error != null
          ? SafeArea(child: Center(child: Text('Error: $_error')))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  backgroundColor: Colors.lightBlue[300],
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      // shorten title a bit for appbar
                      title.length > 40
                          ? '${title.substring(0, 36)}...'
                          : title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey[200]),
                              )
                            : Container(color: Colors.grey[200]),
                        // subtle gradient bottom
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black26],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // meta (source and date)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                source,
                                style: TextStyle(
                                  color: Colors.lightBlue[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                // copy url to clipboard shortcut
                                final url = _detail?['url']?.toString();
                                if (url != null && url.isNotEmpty) {
                                  // quick open share sheet optional - we only show snack
                                  _openUrl(url);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No URL available'),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.open_in_new,
                                color: Colors.lightBlue[700],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // summary card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // summary text with expand control
                                Text(
                                  summary.isEmpty
                                      ? 'No summary available.'
                                      : (_expanded
                                            ? summary
                                            : (summary.length > 300
                                                  ? '${summary.substring(0, 300)}...'
                                                  : summary)),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (summary.length > 300)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => setState(
                                        () => _expanded = !_expanded,
                                      ),
                                      child: Text(
                                        _expanded ? 'Show less' : 'Read more',
                                        style: TextStyle(
                                          color: Colors.lightBlue[700],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // optional additional fields (e.g., summary/other)
                        if ((_detail?['news_site'] ?? _detail?['source']) !=
                            null) ...[
                          const SizedBox(height: 6),
                        ],

                        const SizedBox(
                          height: 80,
                        ), // padding to allow FAB overlap
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _loading || _detail == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.lightBlue[400],
                onPressed: () => _openUrl(_detail?['url']?.toString()),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('See more'),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
