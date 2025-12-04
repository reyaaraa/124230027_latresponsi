import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () => username =
          prefs.getString('loginUser') ?? prefs.getString('username') ?? '',
    );
  }

  Future<void> _confirmLogout() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );

    if (should == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogin', false);
      await prefs.remove('loginUser');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String type,
    required String assetOrIcon,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListPage(menuType: type, username: username),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  assetOrIcon == 'news'
                      ? Icons.article
                      : assetOrIcon == 'blog'
                      ? Icons.article_outlined
                      : Icons.description,
                  size: 32,
                  color: Colors.lightBlue[700],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, ${username.isEmpty ? 'Username' : username}!'),
        actions: [
          IconButton(onPressed: _confirmLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 18, bottom: 28),
        child: Column(
          children: [
            _buildCard(
              title: 'News',
              subtitle: 'Get the latest spaceflight news from various sources.',
              type: 'articles',
              assetOrIcon: 'news',
            ),
            _buildCard(
              title: 'Blog',
              subtitle: 'In-depth blogs about launches, missions and tech.',
              type: 'blogs',
              assetOrIcon: 'blog',
            ),
            _buildCard(
              title: 'Report',
              subtitle: 'Reports and research from space agencies.',
              type: 'reports',
              assetOrIcon: 'report',
            ),
          ],
        ),
      ),
    );
  }
}
