import 'package:get/get.dart';
import 'package:tiddart/page/cart_page.dart';
import '../page/chat_page.dart';
import '../page/favorites_page.dart';
import '../page/home_page.dart';
import '../page/login_page.dart';
import '../page/main_navigation.dart';
import '../page/payment_page.dart';
import '../page/pswd_oublie_page.dart';
import '../page/signup_page.dart';
import '../page/valid_code_page.dart';
import '../page/profile_page.dart';
import '../page/product_details_page.dart';

import '../page/Product_categories_Page.dart';
import '../page/category_selector_page.dart';
import '../page/cosmetics_page.dart';
import '../page/decoration_page.dart';
import '../page/food_page.dart';
import '../page/promotions_page.dart';
import '../page/textile_page.dart';
import '../page/welcome_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String promotions = '/promotions';
  static const String mainNavigation = '/mainNavigation';
  static const String paymentPage = '/paymentPage';
  static const String pswdOubliePage = '/pswdOubliePage';
  static const String validCodePage = '/validCodePage';
  static const String categories = '/categories';
  static const String cosmetics = '/cosmetics';
  static const String food = '/food';
  static const String decoration = '/decoration';
  static const String textile = '/textile';
  static const String categorySelector = '/select-category';
  static const String welcome = '/welcome';
  static const String productDetails = '/product-details';
}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignUpPage()),
    GetPage(name: AppRoutes.home, page: () => HomePage()), // 
    GetPage(name: AppRoutes.cart, page: () => CartPage()), // 
    GetPage(name: AppRoutes.favorites, page: () => FavoritesPage()),
    GetPage(name: AppRoutes.profile, page: () => ProfilePage()),
    GetPage(name: AppRoutes.chat, page: () => ChatPage()),
    GetPage(name: AppRoutes.mainNavigation, page: () => MainNavigation()),
    GetPage(name: AppRoutes.promotions, page: () => PromotionsPage()),
    GetPage(name: AppRoutes.pswdOubliePage, page: () => PswdOubliePage()),
    GetPage(name: AppRoutes.validCodePage, page: () => ValidCodePage()),
    GetPage(name: AppRoutes.categories, page: () => ProductCategoriesPage()),
    GetPage(name: AppRoutes.cosmetics, page: () => CosmeticsPage()),
    GetPage(name: AppRoutes.food, page: () => FoodPage()),
    GetPage(name: AppRoutes.decoration, page: () => DecorationPage()),
    GetPage(name: AppRoutes.textile, page: () => TextilePage()),
    GetPage(name: AppRoutes.categorySelector, page: () => const CategorySelectorPage()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => ProductDetailsPage(
        product: Get.arguments,
      ),
    ),
  ];
}
