import 'package:flutter/material.dart';
import 'login_or_signup_screen.dart'; // ✅ Halaman Login or Sign Up

// ============================================================
//  SIGN UP SCREEN - TABUNGANKU
//  Muncul ketika user menekan tombol Register di ProfileScreen
// ============================================================

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF72),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),

            // ── TOMBOL LANJUT DENGAN GOOGLE ──────────────────────
            _buildGoogleButton(context),

            const SizedBox(height: 12),

            // ── TEKS KETERANGAN ──────────────────────────────────
            const Center(
              child: Text(
                'untuk melanjutkan pendaftaran',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A5C2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── TOMBOL LOGIN ATAU REGISTER ────────────────────────
            // ✅ Navigasi ke LoginOrSignUpScreen
            _buildLoginRegisterButton(context),
          ],
        ),
      ),
    );
  }

  // ── TOMBOL GOOGLE ─────────────────────────────────────────────
  Widget _buildGoogleButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSnackbar(context, 'Lanjut dengan Google'),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lanjut dengan Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              _buildGoogleLogo(),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOMBOL LOGIN ATAU REGISTER ─────────────────────────────────
  Widget _buildLoginRegisterButton(BuildContext context) {
    return GestureDetector(
      // ✅ Navigasi ke LoginOrSignUpScreen
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginOrSignUpScreen()),
      ),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Ikon orang / user
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE7F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF7B1FA2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Login atau register',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── GOOGLE LOGO (4 warna) ──────────────────────────────────────
  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

// ── CUSTOM PAINTER LOGO GOOGLE ─────────────────────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r  = size.width / 2;

    const Color blue   = Color(0xFF4285F4);
    const Color red    = Color(0xFFEA4335);
    const Color yellow = Color(0xFFFBBC05);
    const Color green  = Color(0xFF34A853);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.38;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.62),
      3.14 + 0.3, 1.3, false,
      paint..color = red,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.62),
      4.75, 1.05, false,
      paint..color = yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.62),
      5.8, 0.85, false,
      paint..color = green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.62),
      0.3, 3.14, false,
      paint..color = blue,
    );

    final Paint barPaint = Paint()
      ..color = blue
      ..strokeWidth = r * 0.38
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.62, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}