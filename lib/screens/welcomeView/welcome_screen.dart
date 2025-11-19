import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/appColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trato_hecho_app/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  // --- Theme Helpers ---

  // Updated: Card color now needs to pop against the bottom box
  Color _cardColor(bool isDark) => isDark
      ? AppColors.darkButtons // Dark mode card
      : Colors.white; // Light mode card

  Color _bottomBoxColor(bool isDark) => isDark
      ? AppColors.backgroundDark // Dark mode background for bottom box
      : const Color(0xFFF5F5F5); // Light grey/white for light mode

  Color _textColor(bool isDark) =>
      isDark ? Colors.white : AppColors.textPrimary;

  Color _subTextColor(bool isDark) =>
      isDark ? Colors.grey[400]! : AppColors.textSecondary;

  Color _iconBgColor(bool isDark) =>
      isDark ? Colors.white24 : AppColors.primary.withOpacity(0.1);

  Color _iconColor(bool isDark) => isDark ? Colors.white : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // --- 1. BACKGROUND IMAGE ---
          Positioned.fill(
            // The image stops 20% from the bottom to save rendering behind the box
            bottom: size.height * 0.2,
            child: Image.network(
              'https://plus.unsplash.com/premium_photo-1664303674394-157511e7085d?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.darkButtons,
              ),
            ),
          ),

          // --- 2. DARK OVERLAY ---
          Positioned.fill(
            bottom: size.height * 0.2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. THE BIG BOTTOM BOX ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.27, // Takes up bottom 40% of screen
            child: Container(
              decoration: BoxDecoration(
                color: _bottomBoxColor(isDarkMode),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50), // Rounded top corners
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),

          // --- 4. CONTENT COLUMN ---
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Pushes text down. increased flex to move text lower
                const Spacer(flex: 5),

                // --- TITLE ---
                const Text(
                  'TratoHecho',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4.0,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),

                // --- SUBTITLE ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 8),
                  child: Text(
                    'Encuentra servicios para tus eventos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15, // Smaller size as requested
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- CARDS ROW ---
                // Inside your build method in WelcomeScreen...

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: IntrinsicHeight(
                    // <--- 1. Add this wrapper
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .stretch, // <--- 2. Add this alignment
                      children: [
                        Expanded(
                          child: _SelectionCard(
                            title: 'Encuentra',
                            subtitle:
                                'Estoy buscando contratar a gente para mis eventos / reuniones', // Long text
                            icon: Icons.search,
                            isDarkMode: isDarkMode,
                            cardColor: _cardColor(isDarkMode),
                            textColor: _textColor(isDarkMode),
                            subTextColor: _subTextColor(isDarkMode),
                            iconBgColor: _iconBgColor(isDarkMode),
                            iconColor: _iconColor(isDarkMode),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _SelectionCard(
                            title: 'Ofrecer',
                            subtitle:
                                'Me gustaria ofrecer mis servicios', // Short text
                            icon: Icons.edit_outlined,
                            isDarkMode: isDarkMode,
                            cardColor: _cardColor(isDarkMode),
                            textColor: _textColor(isDarkMode),
                            subTextColor: _subTextColor(isDarkMode),
                            iconBgColor: _iconBgColor(isDarkMode),
                            iconColor: _iconColor(isDarkMode),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- DISCOVER BUTTON ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenWelcome', true);

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const MainNavigator()),
                          );
                        }
                      },
                      child: const Text(
                        'Descubrir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET (Updated with White Border in Dark Mode) ---
class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDarkMode;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _SelectionCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDarkMode,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Optional: Set a minimum height
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),

          // --- CHANGE IS HERE ---
          border: Border.all(
            // If Dark Mode -> White. If Light Mode -> Light Grey
            color: isDarkMode ? Colors.white : Colors.grey.withOpacity(0.1),
            width: 1.5, // Slightly thicker to make the white pop
          ),
          // ---------------------

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subTextColor,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
