import 'package:flutter/material.dart';
import 'package:tiddart/page/cart_page.dart';
import '../theme/app_theme.dart';
import 'chat_list_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const HomePage(),
    CartPage(),
    FavoritesPage(),
    const ChatListPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: AppTheme.primaryBrown,
              unselectedItemColor: AppTheme.primaryBrown.withOpacity(0.5),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.textTheme.bodyMedium?.fontFamily,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: AppTheme.textTheme.bodyMedium?.fontFamily,
                fontSize: 12,
              ),
              selectedIconTheme: IconThemeData(
                color: AppTheme.primaryBrown,
                size: 26,
              ),
              unselectedIconTheme: IconThemeData(
                color: AppTheme.primaryBrown.withOpacity(0.5),
                size: 24,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _currentIndex == 0 
                              ? AppTheme.accentGold 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.home_outlined),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.home),
                  ),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _currentIndex == 1 
                              ? AppTheme.accentGold 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: 'Panier',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _currentIndex == 2 
                              ? AppTheme.accentGold 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.favorite_border),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.favorite),
                  ),
                  label: 'Favoris',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _currentIndex == 3 
                              ? AppTheme.accentGold 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.chat_bubble),
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _currentIndex == 4 
                              ? AppTheme.accentGold 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.person_outline),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.person),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
