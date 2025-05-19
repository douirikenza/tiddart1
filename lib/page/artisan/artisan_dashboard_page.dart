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
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
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
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
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
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: AppTheme.primaryBrown),
            onPressed: () {
              Get.toNamed(AppRoutes.artisanProfile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundLight,
                AppTheme.surfaceLight,
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // En-tête avec statistiques étendues
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildAnimatedCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatCard(
                                      'Produits',
                                      '12',
                                      Icons.inventory,
                                      AppTheme.primaryBrown,
                                      '↑ 2 cette semaine',
                                    ),
                                    _buildStatCard(
                                      'Commandes',
                                      '5',
                                      Icons.shopping_bag,
                                      Colors.green,
                                      '↑ 3 en attente',
                                    ),
                                    _buildStatCard(
                                      'Ventes',
                                      '1.2k TND',
                                      Icons.attach_money,
                                      Colors.orange,
                                      '↑ 15% ce mois',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildRevenueChart(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Actions rapides avec badges de notification
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        // Section des dernières activités améliorée
                        _buildLatestActivities(),
                      ],
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                Get.toNamed(AppRoutes.artisanProfile);
                break;
              case 2:
                Get.toNamed(AppRoutes.categoryManagement);
                break;
              case 3:
                Get.toNamed(AppRoutes.productManagement);
                break;
            }
          },
          selectedItemColor: AppTheme.primaryBrown,
          unselectedItemColor: Colors.grey,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Catégories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Produits',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutQuart,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: _buildGlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                      shadows: [
                        Shadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return Hero(
      tag: UniqueKey(),
      child: Card(
        elevation: 8,
        shadowColor: AppTheme.primaryBrown.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceLight,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.primaryBrown,
                AppTheme.primaryBrown.withOpacity(0.7),
              ],
            ).createShader(bounds),
            child: const Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCardWithBadge(
                context,
                'Gérer les Catégories',
                Icons.category,
                'Ajoutez et gérez vos catégories de produits',
                () => Get.toNamed(AppRoutes.categoryManagement),
                Colors.blue,
                '2',
                0,
              ),
              _buildActionCardWithBadge(
                context,
                'Gérer les Produits',
                Icons.inventory,
                'Ajoutez et gérez vos produits',
                () => Get.toNamed(AppRoutes.productManagement),
                AppTheme.primaryBrown,
                '3',
                1,
              ),
              _buildActionCardWithBadge(
                context,
                'Commandes',
                Icons.shopping_bag,
                'Gérez vos commandes en cours',
                () => _showFeatureComingSoon(context),
                Colors.green,
                '5',
                2,
              ),
              _buildActionCardWithBadge(
                context,
                'Statistiques',
                Icons.analytics,
                'Consultez vos statistiques de vente',
                () => _showFeatureComingSoon(context),
                Colors.orange,
                '',
                3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardWithBadge(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
    Color color,
    String badgeCount,
    int index,
  ) {
    return MouseRegion(
      onEnter: (_) => setState(() => _cardHovered[index] = true),
      onExit: (_) => setState(() => _cardHovered[index] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _cardHovered[index] ? -8.0 : 0.0,
            0.0,
          ),
        child: Stack(
          key: _cardKeys[index],
          children: [
            _buildGlassmorphicCard(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                          shadows: [
                            Shadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDark.withOpacity(0.7),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (badgeCount.isNotEmpty)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    badgeCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return _buildGlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenus hebdomadaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBrown,
                shadows: [
                  Shadow(
                    color: AppTheme.primaryBrown.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: ChartPainter(
                  data: _chartData.map((e) => e.amount).toList(),
                  labels: _chartData.map((e) => e.day).toList(),
                  color: AppTheme.primaryBrown,
                ),
                size: const Size(double.infinity, 200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestActivities() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildAnimatedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppTheme.primaryBrown,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dernières Activités',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Nouvelle commande reçue',
              'Il y a 2 heures',
              Icons.notifications,
              Colors.green,
            ),
            _buildDivider(),
            _buildActivityItem(
              'Produit ajouté : Tapis berbère',
              'Il y a 5 heures',
              Icons.add_circle,
              Colors.blue,
            ),
            _buildDivider(),
            _buildActivityItem(
              'Commande #123 livrée',
              'Il y a 1 jour',
              Icons.check_circle,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        color: AppTheme.primaryBrown.withOpacity(0.1),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Animation de pulsation au toucher
        Get.snackbar(
          title,
          time,
          backgroundColor: color.withOpacity(0.1),
          colorText: color,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
          icon: Icon(icon, color: color),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textDark.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppTheme.surfaceLight,
          title: Row(
            children: [
              Icon(
                Icons.upcoming,
                color: AppTheme.primaryBrown,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Fonctionnalité à venir',
                style: TextStyle(
                  color: AppTheme.primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cette fonctionnalité sera bientôt disponible !',
                style: TextStyle(
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.construction,
                color: AppTheme.primaryBrown.withOpacity(0.5),
                size: 48,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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