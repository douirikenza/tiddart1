import 'package:get/get.dart';
import '../page/artisan/artisan_dashboard_page.dart';
import '../page/artisan/artisan_profile_page.dart';
import '../page/artisan/category_management_page.dart';
import '../page/artisan/product_management_page.dart';
import '../page/artisan/order_statistics_page.dart';
import '../page/artisan/category_products_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.artisanDashboard,
      page: () => ArtisanDashboardPage(artisanId: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.categoryManagement,
      page: () => CategoryManagementPage(),
    ),
    GetPage(
      name: AppRoutes.productManagement,
      page: () => ProductManagementPage(),
    ),
    GetPage(
      name: AppRoutes.artisanProfile,
      page: () => const ArtisanProfilePage(),
    ),
    GetPage(
      name: AppRoutes.orderStatistics,
      page: () => OrderStatisticsPage(),
    ),
    GetPage(
      name: AppRoutes.artisanCategoryProducts,
      page: () => CategoryProductsPage(),
    ),
  ];
} 