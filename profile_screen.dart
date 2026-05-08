import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
//  PROFILE SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _namaController  = TextEditingController(text: 'Mas Amba');
  final TextEditingController _hpController    = TextEditingController(text: '123456789');
  final TextEditingController _emailController = TextEditingController(text: 'Ambakang@gmail.com');

  final FocusNode _namaFocus  = FocusNode();
  final FocusNode _hpFocus    = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  String _savedNama  = 'Mas Amba';
  String _savedHp    = '123456789';
  String _savedEmail = 'Ambakang@gmail.com';

  bool _namaEditing  = false;
  bool _hpEditing    = false;
  bool _emailEditing = false;

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _emailController.dispose();
    _namaFocus.dispose();
    _hpFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _konfirmasi(String field) {
    setState(() {
      switch (field) {
        case 'nama':
          final val = _namaController.text.trim();
          if (val.isEmpty) { _showSnackbar('Nama tidak boleh kosong!', isError: true); return; }
          _savedNama = val; _namaEditing = false; _namaFocus.unfocus(); break;
        case 'hp':
          final val = _hpController.text.trim();
          if (val.isEmpty) { _showSnackbar('No. Handphone tidak boleh kosong!', isError: true); return; }
          _savedHp = val; _hpEditing = false; _hpFocus.unfocus(); break;
        case 'email':
          final val = _emailController.text.trim();
          if (val.isEmpty) { _showSnackbar('Email tidak boleh kosong!', isError: true); return; }
          if (!val.contains('@') || !val.contains('.')) { _showSnackbar('Format email tidak valid!', isError: true); return; }
          _savedEmail = val; _emailEditing = false; _emailFocus.unfocus(); break;
      }
    });
    _showSnackbar('Berhasil disimpan!');
  }

  void _hapus(String field) {
    setState(() {
      switch (field) {
        case 'nama':
          _namaController.clear(); _namaEditing = true;
          Future.delayed(const Duration(milliseconds: 100), () => _namaFocus.requestFocus()); break;
        case 'hp':
          _hpController.clear(); _hpEditing = true;
          Future.delayed(const Duration(milliseconds: 100), () => _hpFocus.requestFocus()); break;
        case 'email':
          _emailController.clear(); _emailEditing = true;
          Future.delayed(const Duration(milliseconds: 100), () => _emailFocus.requestFocus()); break;
      }
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF4CAF72),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Profil Saya'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AVATAR ────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFF4CAF72).withOpacity(0.15),
                      child: const Icon(Icons.person, size: 56, color: Color(0xFF4CAF72)),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF72),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildProfileField(
                label: 'Nama', savedValue: _savedNama,
                controller: _namaController, focusNode: _namaFocus, fieldKey: 'nama',
                isEditing: _namaEditing, keyboardType: TextInputType.name, isDark: isDark,
                onChanged: (_) => setState(() => _namaEditing = true),
              ),
              const SizedBox(height: 8),
              _buildProfileField(
                label: 'No. Handphone', savedValue: _savedHp,
                controller: _hpController, focusNode: _hpFocus, fieldKey: 'hp',
                isEditing: _hpEditing, keyboardType: TextInputType.phone, isDark: isDark,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _hpEditing = true),
              ),
              const SizedBox(height: 8),
              _buildProfileField(
                label: 'Email', savedValue: _savedEmail,
                controller: _emailController, focusNode: _emailFocus, fieldKey: 'email',
                isEditing: _emailEditing, keyboardType: TextInputType.emailAddress, isDark: isDark,
                onChanged: (_) => setState(() => _emailEditing = true),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: _buildAuthButton(
                      label: 'Login', isDark: isDark,
                      child: Image.network('https://www.google.com/favicon.ico',
                          width: 28, height: 28,
                          errorBuilder: (_, _, _) => Icon(Icons.login, size: 28,
                              color: isDark ? Colors.white54 : Colors.grey)),
                      onTap: () => _showSnackbar('Login dengan Google'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAuthButton(
                      label: 'Register', isDark: isDark,
                      child: Text('Sign Up?',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF9FA8DA) : const Color(0xFF5C6BC0))),
                      onTap: () => _showSnackbar('Register akun baru'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String savedValue,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String fieldKey,
    required bool isEditing,
    required TextInputType keyboardType,
    required bool isDark,
    List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
  }) {
    final Color textColor      = isDark ? Colors.white : Colors.black87;
    final Color subTextColor   = isDark ? Colors.white54 : Colors.black54;
    final Color dividerColor   = isDark ? Colors.white12 : Colors.black12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: dividerColor, height: 1),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(width: 8),
            if (!isEditing && savedValue.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF72).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Tersimpan ✓',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF72))),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                onChanged: onChanged,
                style: TextStyle(fontSize: 14, color: subTextColor),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  border: InputBorder.none,
                  hintText: 'Masukkan data...',
                  hintStyle: TextStyle(fontSize: 14,
                      color: isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () => _hapus(fieldKey),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 14,
                      color: isDark ? Colors.white54 : Colors.black45),
                ),
              ),
            GestureDetector(
              onTap: () => _konfirmasi(fieldKey),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF72),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Konfirmasi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: dividerColor, height: 1),
      ],
    );
  }

  Widget _buildAuthButton({
    required String label,
    required Widget child,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.black54)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Center(child: child),
          ),
        ),
      ],
    );
  }
}