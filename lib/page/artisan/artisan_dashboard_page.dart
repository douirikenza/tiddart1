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
import 'category_products_page.dart';

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
  
  // Nouvelles animations pour les cartes
  final List<GlobalKey> _cardKeys = List.generate(4, (index) => GlobalKey());
  final List<bool> _cardHovered = List.generate(4, (index) => false);

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
    
    // Simuler un chargement
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
    // TODO: Remplacer ces valeurs par des valeurs dynamiques si besoin
    final int nbProduits = 0; // À remplacer par le vrai nombre de produits
    final int nbCommandes = 0; // À remplacer par le vrai nombre de commandes

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Tableau de Bord Artisan',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          StreamBuilder<int>(
            stream: _messageController.getUnreadCount(widget.artisanId),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: unreadCount > 0 ? value : 1.0,
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.primaryBrown,
                            size: 26,
                          ),
                        );
                      },
                    ),
                    onPressed: () {
                      Get.to(
                        () => ArtisanConversationsList(artisanId: widget.artisanId),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: AppTheme.primaryBrown),
            onPressed: () {
              Get.to(() => CategoryProductsPage());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Text(
                'Bienvenue sur votre espace artisan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppTheme.primaryBrown,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Produits', Icons.inventory_2, nbProduits, Colors.blue.shade50, Colors.blue),
                _buildStatCard('Commandes', Icons.shopping_cart, nbCommandes, Colors.orange.shade50, Colors.orange),
                _buildStatCard('Statistiques', Icons.bar_chart, '', Colors.green.shade50, Colors.green),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Gestion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  'Mes produits',
                  Icons.inventory_2,
                  Colors.blue.shade50,
                  Colors.blue,
                  () => Get.to(() => ArtisanProductManagementPage()),
                ),
                _buildActionCard(
                  'Mes commandes',
                  Icons.shopping_cart,
                  Colors.orange.shade50,
                  Colors.orange,
                  () {/* TODO: Navigation vers la page de gestion des commandes */},
                ),
                _buildActionCard(
                  'Statistiques',
                  Icons.bar_chart,
                  Colors.green.shade50,
                  Colors.green,
                  () {/* TODO: Navigation vers la page de statistiques */},
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, IconData icon, dynamic value, Color bgColor, Color iconColor) {
    return Container(
      width: 110,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: iconColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: iconColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: iconColor.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Implementation of _showAddProductDialog method
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