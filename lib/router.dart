import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nabtati/plantDesign.dart';

import 'auth/welcomPage.dart';
import 'auth/loginPage.dart';
import 'auth/registerPage.dart';
import 'homePage.dart';

import 'plants_page.dart';
import 'mygarden/plant_details_page.dart';

import 'plant_model.dart';
import 'garden.dart';
import 'mygarden/edit_plant_page.dart';

import 'community/community_page.dart';
import 'searchPage.dart';
import 'profile.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Welcome Page
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),

    // Auth pages
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // Main nav bar
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: ModernBottomNavBar(
            currentPath: state.uri.path,
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) =>  HomeContent(),
        ),
        GoRoute(
          path: '/garden',
          builder: (context, state) => const Garden(),
        ),
        
     /*   GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityPage(),
        ),
        */
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
       /* GoRoute(
        path: '/garden/details',
        builder: (context, state) {
          final plant = state.extra as Plant;
          return PlantDetailsPage(plant: plant,);
        },
        ),*/
       
          GoRoute(
            path: '/plantPage',
            builder: (context, state) {
              final plant = state.extra as Plant;
              return PlantDesign(plant: plant);
            },
          ),

         GoRoute(
          path: '/searchPage',
          builder: (context, state) => const SearchPage(),
        ),
      ],
    ),
  ],
);





class ModernBottomNavBar extends StatelessWidget {
  final String currentPath;

  const ModernBottomNavBar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      NavItem(
        icon: Icons.home_rounded,
        label: 'الرئيسية',
        route: '/home',
        color: const Color.fromARGB(255, 226, 152, 189),
      ),
      NavItem(
        icon: Icons.grass_rounded,
        label: 'حديقتي',
        route: '/garden',
        color: const Color.fromARGB(255, 78, 170, 21),
      ),
      NavItem(
        icon: Icons.groups_rounded,
        label: 'المجتمع',
        route: '/community',
        color: const Color.fromARGB(255, 174, 158, 220),
      ),
      NavItem(
        icon: Icons.person_rounded,
        label: 'حسابي',
        route: '/profile',
        color: const Color.fromARGB(255, 155, 124, 185),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA18AB7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = currentPath == item.route;
              return _NavBarItem(
                item: item,
                isSelected: isSelected,
                onTap: () => context.go(item.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class _NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? item.color.withOpacity(0.23) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? item.color.withOpacity(0.3) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? item.color : const Color.fromARGB(255, 128, 127, 127),
                size: isSelected ? 28 : 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
