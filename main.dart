import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme_notifier.dart';

void main() {
  runApp(const TabunganKuApp());
}

class TabunganKuApp extends StatelessWidget {
  const TabunganKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) {
        return MaterialApp(
          title: 'TabunganKu',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // ── LIGHT THEME ────────────────────────────────
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF72),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              iconTheme: IconThemeData(color: Colors.black87),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF4CAF72),
              unselectedItemColor: Colors.grey,
            ),
            cardColor: Colors.white,
            dividerColor: Colors.black12,
          ),

          // ── DARK THEME ─────────────────────────────────
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF72),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFF4CAF72),
              unselectedItemColor: Colors.grey,
            ),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.white12,
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}

// ============================================================
//  SPLASH SCREEN
// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF72),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('TABUNGANKU',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Color(0xFF212121),
                      )),
                  SizedBox(height: 4),
                  Text('TABUNGAN DIGITAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.5,
                        color: Color(0xFF424242),
                      )),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 1.5,
                height: 50,
                color: const Color(0xFF2D2D2D),
              ),
              const Icon(Icons.account_balance_wallet_rounded,
                  size: 52, color: Color(0xFF2D2D2D)),
            ],
          ),
        ),
      ),
    );
  }
}