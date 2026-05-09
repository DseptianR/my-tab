import 'package:flutter/material.dart';

// ============================================================
//  LOGIN OR SIGN UP SCREEN - TABUNGANKU
//  Muncul saat user menekan "Login atau register" di SignUpScreen
//  Desain: field Email → "Atau" → tombol Lanjut dengan Google
// ============================================================

class LoginOrSignUpScreen extends StatefulWidget {
  const LoginOrSignUpScreen({super.key});

  @override
  State<LoginOrSignUpScreen> createState() => _LoginOrSignUpScreenState();
}

class _LoginOrSignUpScreenState extends State<LoginOrSignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _isEmailValid = true; // true = tidak ada error

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  // ── VALIDASI & LANJUT VIA EMAIL ──────────────────────────────
  void _onLanjutEmail() {
    final String email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _isEmailValid = false);
      _snack('Masukkan email yang valid!', isError: true);
      return;
    }
    setState(() => _isEmailValid = true);
    _emailFocus.unfocus();
    _snack('Melanjutkan dengan email: $email');
    // TODO: navigasi ke halaman berikutnya (misalnya OTP / password)
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
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
          'Login or Sign Up',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // ── LABEL EMAIL ──────────────────────────────────
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A5C2E),
                ),
              ),
              const SizedBox(height: 8),

              // ── FIELD EMAIL ───────────────────────────────────
              _buildEmailField(),

              const SizedBox(height: 20),

              // ── ATAU ─────────────────────────────────────────
              const Center(
                child: Text(
                  'Atau',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A5C2E),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── TOMBOL LANJUT DENGAN GOOGLE ──────────────────
              _buildGoogleButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── FIELD EMAIL ───────────────────────────────────────────────
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: _isEmailValid
            ? null
            : Border.all(color: const Color(0xFFE53935), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (!_isEmailValid) setState(() => _isEmailValid = true);
              },
              onSubmitted: (_) => _onLanjutEmail(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
                hintText: 'Masukkan email kamu',
                hintStyle: TextStyle(fontSize: 14, color: Colors.black26),
              ),
            ),
          ),
          // Tombol anak panah untuk lanjut
          GestureDetector(
            onTap: _onLanjutEmail,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOMBOL LANJUT DENGAN GOOGLE ───────────────────────────────
  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: () => _snack('Lanjut dengan Google'),
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
              // Google logo
              SizedBox(
                width: 28,
                height: 28,
                child: CustomPaint(painter: _GoogleLogoPainter()),
              ),
              const SizedBox(width: 14),
              const Text(
                'Lanjut dengan Google',
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