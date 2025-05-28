import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../controllers/message_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'artisan_chat_page.dart';
import 'artisan_conversations_list.dart';
import 'artisan_product_management_page.dart';
import 'artisan_dashboard_profile.dart';
import '../../controllers/artisan_controller.dart';

class RevenueData {
  final String day;
  final double amount;

  RevenueData(this.day, this.amount);
}

class ArtisanDashboardPage extends StatefulWidget {
  final String artisanId;
  
  const ArtisanDashboardPage({
    Key? key,
    required this.artisanId,
  }) : super(key: key);

  @override
  State<ArtisanDashboardPage> createState() => _ArtisanDashboardPageState();
}

class _ArtisanDashboardPageState extends State<ArtisanDashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  int _currentIndex = 0;
  
  late List<RevenueData> _chartData;
  final MessageController _messageController = Get.put(MessageController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ArtisanController artisanController = Get.put(ArtisanController());

  @override
  void initState() {
    super.initState();
    _initChartData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
    artisanController.fetchArtisan(widget.artisanId);
  }

  void _initChartData() {
    _chartData = [
      RevenueData('Lun', 150),
      RevenueData('Mar', 230),
      RevenueData('Mer', 180),
      RevenueData('Jeu', 320),
      RevenueData('Ven', 260),
      RevenueData('Sam', 310),
      RevenueData('Dim', 280),
    ];
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF8D5524);
    final Color bgColor = const Color(0xFFF7F3EF);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: _buildDrawer(mainColor),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB4846C), Color(0xFF8D5524)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
          'Tableau de Bord Artisan',
          style: TextStyle(
                          color: Colors.white,
            fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                      onPressed: () {
                        Get.to(
                          () => ArtisanConversationsList(artisanId: widget.artisanId),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                    ),
                  ),
                    Positioned(
                      right: 8,
                      top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () => Get.to(() => const ArtisanDashboardProfile()),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                // Header avec photo et nom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Obx(() {
                    final artisan = artisanController.artisan.value;
                    return Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [mainColor.withOpacity(0.7), mainColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: artisan?.photoUrl != null && artisan!.photoUrl!.isNotEmpty
                                ? NetworkImage(artisan.photoUrl!)
                                : const AssetImage('assets/icons/placeholder.png') as ImageProvider,
                            radius: 30,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artisan?.nom ?? 'Artisan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            if (artisan?.email != null && artisan!.email!.isNotEmpty)
                              Text(
                                artisan.email!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            if (artisan?.telephone != null && artisan!.telephone!.isNotEmpty)
                              Text(
                                artisan.telephone!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 4),
                            const Text(
                              'Bienvenue !',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                    ),
                ],
              );
                  }),
                ),
              ],
            ),
          ),
          ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Get.to(() => ArtisanProductManagementPage()),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              width: 260,
              height: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inventory, color: mainColor, size: 48),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Gérer les produits',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8D5524),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ajouter ou gérer vos produits',
                    style: TextStyle(
                      fontSize: 15,
                      color: mainColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                // Déjà sur le dashboard
                break;
              case 1:
                Get.to(() => const ArtisanDashboardProfile());
                break;
            }
          },
          selectedItemColor: mainColor,
          unselectedItemColor: Colors.brown.shade200,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(Color mainColor) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor.withOpacity(0.8), mainColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Obx(() {
              final artisan = artisanController.artisan.value;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: artisan?.photoUrl != null && artisan!.photoUrl!.isNotEmpty
                        ? NetworkImage(artisan.photoUrl!)
                        : const AssetImage('assets/icons/placeholder.png') as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artisan?.nom ?? 'Artisan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (artisan?.email != null && artisan!.email!.isNotEmpty)
                        Text(
                          artisan.email!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      if (artisan?.telephone != null && artisan!.telephone!.isNotEmpty)
                        Text(
                          artisan.telephone!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 6),
                      const Text(
                        'Artisan connecté',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFF8D5524)),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF8D5524)),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const ArtisanDashboardProfile());
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory, color: Color(0xFF8D5524)),
            title: const Text('Produits'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ArtisanProductManagementPage());
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion'),
            onTap: () {
              Get.offAllNamed('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;

  ChartPainter({
    required this.data,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] / maxValue * size.height * 0.8);
      points.add(Offset(x, y));
    }

    // Draw area
    final path = Path()
      ..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlPoint1 = Offset(
        p0.dx + (p1.dx - p0.dx) / 2,
        p0.dy,
      );
      final controlPoint2 = Offset(
        p0.dx + (p1.dx - p0.dx) / 2,
        p1.dy,
      );
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots and labels
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(point, 6, dotBorderPaint);

      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: color.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          point.dx - textPainter.width / 2,
          size.height - 20,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 