import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'semua_surat_screen.dart';
import 'laporan_screen.dart';
import 'surat_masuk_screen.dart';
import 'surat_keluar_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userRole = "";

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    String role = await AuthService().getUserRole();
    setState(() {
      _userRole = role;
    });
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          int crossAxisCount = orientation == Orientation.portrait ? 2 : 3;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    orientation == Orientation.portrait ? 1.2 : 1.5,
              ),
              children: _buildMenuItems(),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> menuItems = [
      _buildMenuItem(
        context,
        icon: Icons.email,
        title: "Surat Masuk",
        color: Colors.green,
        screen: SuratMasukScreen(),
      ),
      _buildMenuItem(
        context,
        icon: Icons.outbox,
        title: "Surat Keluar",
        color: Colors.orange,
        screen: SuratKeluarScreen(),
      ),
      _buildMenuItem(
        context,
        icon: Icons.all_inbox,
        title: "Semua Surat",
        color: Colors.purple,
        screen: SemuaSuratScreen(),
      ),
    ];

    if (_userRole == "Kepala") {
      menuItems.add(
        _buildMenuItem(
          context,
          icon: Icons.insert_chart,
          title: "Laporan",
          color: Colors.blue,
          screen: LaporanScreen(),
        ),
      );
    }

    return menuItems;
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required Widget screen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
