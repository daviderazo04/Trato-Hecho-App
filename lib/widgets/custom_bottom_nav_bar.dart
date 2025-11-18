import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import this for thinner icons
import 'package:provider/provider.dart';
import '../../config/appColors.dart';
import '../../config/theme_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasUnreadMessages;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnreadMessages = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    const Color activeColor = Color.fromARGB(255, 255, 255, 255);
    const Color inactiveColor = Color.fromARGB(190, 255, 255, 255);

    return BottomAppBar(
      color: isDarkMode ? AppColors.backgroundDark : Colors.white,
      elevation: 0,
      child: Container(
        // --- CHANGE 1: Taller (Larger) ---
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),

        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkButtons : AppColors.primary,
          borderRadius:
              BorderRadius.circular(30.0), // Slightly rounder to match new size
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorders : AppColors.border,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // --- CHANGE 3: Thinner Icons (Cupertino) ---

            // 1. Home
            IconButton(
              // CupertinoIcons.house is much thinner than Icons.home_outlined
              icon: Icon(currentIndex == 0
                  ? CupertinoIcons.house_fill
                  : CupertinoIcons.house),
              color: currentIndex == 0 ? activeColor : inactiveColor,
              iconSize:
                  30.0, // Kept size roughly same (Cupertino is visually larger, so 30 is good)
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onTap(0),
            ),

            // 2. Search
            IconButton(
              // Cupertino Search is very thin
              icon: const Icon(CupertinoIcons.search),
              // Bold/Fill doesn't really exist for search, so we rely on color/opacity
              color: currentIndex == 1 ? activeColor : inactiveColor,
              iconSize: 30.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onTap(1),
            ),

            // 3. Chat
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(currentIndex == 2
                      ? CupertinoIcons.chat_bubble_fill
                      : CupertinoIcons.chat_bubble),
                  color: currentIndex == 2 ? activeColor : inactiveColor,
                  iconSize: 30.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onTap(2),
                ),
                if (hasUnreadMessages)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.notificacion,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.darkButtons
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 4. Profile
            IconButton(
              icon: Icon(currentIndex == 3
                  ? CupertinoIcons.person_fill
                  : CupertinoIcons.person),
              color: currentIndex == 3 ? activeColor : inactiveColor,
              iconSize: 30.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
