import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'category_management_page.dart';
import 'artisan_management_page.dart';
import '../../controllers/admin_dashboard_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  final String adminId;

  const AdminDashboardPage({Key? key, required this.adminId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller = Get.put(AdminDashboardController());
    final Color mainColor = const Color(0xFF8D5524); // Marron principal
    final Color bgColor = const Color(0xFFF7F3EF); // Fond doux
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
            child: Row(
              children: [
                const SizedBox(width: 24),
                const Icon(Icons.dashboard, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
          'Dashboard Administrateur',
          style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 0.5,
          ),
        ),
                ),
          IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout, color: Colors.white, size: 24),
                  ),
                  onPressed: () async {
                    // await FirebaseAuth.instance.signOut();
                    Get.offAllNamed('/login');
            },
                  tooltip: 'Déconnexion',
                ),
                const SizedBox(width: 16),
        ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue sur votre tableau de bord',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8D5524),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatCard(
                          'Total Artisans',
                        controller.totalArtisans,
                          Icons.people,
                        const Color(0xFF4A90E2),
                      ),
                      const SizedBox(width: 18),
                      _buildStatCard(
                          'Catégories',
                        controller.totalCategories,
                          Icons.category,
                        const Color(0xFF50C878),
                      ),
                      const SizedBox(width: 18),
                      _buildStatCard(
                          'Commandes',
                        controller.totalCommandes,
                          Icons.shopping_cart,
                        const Color(0xFFFFA726),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestion de la plateforme',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8D5524),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1,
                    children: [
                      _buildDashboardCard(
                        'Gestion des catégories',
                        Icons.category,
                        const Color(0xFF4A90E2),
                        () => Get.to(() => AdminCategoryManagementPage()),
                      ),
                      _buildDashboardCard(
                        'Gestion des artisans',
                        Icons.people,
                        const Color(0xFF50C878),
                        () => Get.to(() => AdminArtisanManagementPage()),
                      ),
                      _buildDashboardCard(
                        'Statistiques',
                        Icons.bar_chart,
                        const Color(0xFFFFA726),
                        () {
                          // TODO: Navigation vers les statistiques
                        },
                      ),
                      _buildDashboardCard(
                        'Paramètres',
                        Icons.settings,
                        const Color(0xFF9C27B0),
                        () {
                          // TODO: Navigation vers les paramètres
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, RxInt value, IconData icon, Color color) {
    return Expanded(
      child: Obx(() => Container(
        margin: const EdgeInsets.only(right: 0),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.13),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              value.value.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8D5524),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.13),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8D5524),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 