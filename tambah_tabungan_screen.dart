import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'settings_screen.dart';
import 'statistik_screen.dart';

// ============================================================
//  TAMBAH TABUNGAN SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

class TambahTabunganScreen extends StatefulWidget {
  const TambahTabunganScreen({super.key});

  @override
  State<TambahTabunganScreen> createState() => _TambahTabunganScreenState();
}

class _TambahTabunganScreenState extends State<TambahTabunganScreen> {
  final TextEditingController _namaController    = TextEditingController();
  final TextEditingController _targetController  = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  String  _selectedRencana = 'Mingguan';
  XFile?  _pickedImage;
  bool    _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _namaController.dispose();
    _targetController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  // ✅ FIX: Tampilkan bottom sheet pilih sumber gambar (Kamera / Galeri)
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Pilih Sumber Gambar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4CAF72),
                  child: Icon(Icons.photo_library, color: Colors.white, size: 20),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1565C0),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_pickedImage != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE53935),
                    child: Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  title: const Text('Hapus Gambar'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _pickedImage = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX: pickImage dengan error handling lengkap
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 900,
      );
      // ✅ FIX: Cek mounted sebelum setState
      if (!mounted) return;
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      // ✅ FIX: Tangkap error permission dengan pesan yang jelas
      String pesan = 'Gagal membuka sumber gambar.';
      if (e.code == 'photo_access_denied') {
        pesan = 'Izin galeri ditolak. Buka Pengaturan → Izin Aplikasi untuk mengaktifkan.';
      } else if (e.code == 'camera_access_denied') {
        pesan = 'Izin kamera ditolak. Buka Pengaturan → Izin Aplikasi untuk mengaktifkan.';
      }
      _showSnackbar(pesan, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Gagal memilih gambar: $e', isError: true);
    }
  }

  // ✅ FIX: Validasi input angka + mounted check
  void _onSave() {
    final nama    = _namaController.text.trim();
    final target  = _targetController.text.trim();
    final nominal = _nominalController.text.trim();

    if (nama.isEmpty) {
      _showSnackbar('Nama tabungan tidak boleh kosong!', isError: true); return;
    }
    if (target.isEmpty) {
      _showSnackbar('Target tidak boleh kosong!', isError: true); return;
    }
    if (nominal.isEmpty) {
      _showSnackbar('Nominal pengisian tidak boleh kosong!', isError: true); return;
    }

    // ✅ FIX: Validasi parsing angka agar tidak crash
    final double? targetVal  = double.tryParse(target);
    final double? nominalVal = double.tryParse(nominal);

    if (targetVal == null || targetVal <= 0) {
      _showSnackbar('Target harus berupa angka yang valid!', isError: true); return;
    }
    if (nominalVal == null || nominalVal <= 0) {
      _showSnackbar('Nominal harus berupa angka yang valid!', isError: true); return;
    }
    if (nominalVal > targetVal) {
      _showSnackbar('Nominal pengisian tidak boleh melebihi target!', isError: true); return;
    }

    setState(() => _isLoading = true);

    // Buat tanggal sekarang
    final now = DateTime.now();
    const bulanList = ['', 'Januari','Februari','Maret','April','Mei','Juni',
        'Juli','Agustus','September','Oktober','November','Desember'];
    final createdDate = '${now.day} ${bulanList[now.month]} ${now.year}';

    // Hitung estimasi berdasarkan rencana pengisian
    int periodDays = _selectedRencana == 'Harian' ? 1
                   : _selectedRencana == 'Mingguan' ? 7 : 30;
    int periodsNeeded = (targetVal / nominalVal).ceil();
    final estimasiDate = now.add(Duration(days: periodsNeeded * periodDays));
    final estimasiStr  = '${bulanList[estimasiDate.month]} ${estimasiDate.year}';

    // ✅ FIX: Buat SavingGoal dengan localImagePath dari _pickedImage?.path
    final newGoal = SavingGoal(
      title: nama,
      localImagePath: _pickedImage?.path,   // null jika tidak pilih gambar
      imageUrl: null,
      targetAmount: targetVal,
      collectedAmount: 0,
      savingPerPeriod: nominalVal.toInt(),
      rencana: _selectedRencana,
      createdDate: createdDate,
      estimasiDate: estimasiStr,
      isCompleted: false,
    );

    // ✅ FIX: Cek mounted sebelum setState & pop
    if (!mounted) return;
    setState(() => _isLoading = false);

    // ✅ KRITIS: pop dengan newGoal agar StatistikScreen menerima data
    Navigator.of(context).pop(newGoal);
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF72),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Tambah tabungan',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── IMAGE PICKER ──────────────────────────────
              _buildImagePicker(),
              const SizedBox(height: 20),

              // ── NAMA ──────────────────────────────────────
              _buildLabel('Nama'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _namaController,
                keyboardType: TextInputType.text,
                hint: 'Nama tabungan',
              ),
              const SizedBox(height: 16),

              // ── TARGET ────────────────────────────────────
              _buildLabel('Target'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefix: 'Rp. ',
                hint: '0',
              ),
              const SizedBox(height: 16),

              // ── RENCANA PENGISIAN ─────────────────────────
              _buildLabel('Rencana Pengisian'),
              const SizedBox(height: 10),
              _buildRencanaSelector(),
              const SizedBox(height: 16),

              // ── NOMINAL PENGISIAN ─────────────────────────
              _buildLabel('Nominal Pengisian'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                compact: true,
                prefix: 'Rp. ',
                hint: '0',
              ),
              const SizedBox(height: 36),

              // ── SAVE BUTTON ───────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _isLoading ? null : _onSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2E7D32)))
                        : const Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32)),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX: Tap panggil _showImageSourceSheet() bukan langsung galeri
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: _pickedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ FIX: Gunakan Image.file dengan File() yang benar
                  Image.file(
                    File(_pickedImage!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholderContent(),
                  ),
                  // Overlay tombol ganti foto
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Ganti',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _imagePlaceholderContent(),
      ),
    );
  }

  Widget _imagePlaceholderContent() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 48, color: Colors.black45),
          SizedBox(height: 8),
          Text(
            'Tap untuk pilih gambar',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          SizedBox(height: 4),
          Text(
            'Galeri atau Kamera',
            style: TextStyle(fontSize: 11, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool compact = false,
    String? prefix,
    String? hint,
  }) {
    return Container(
      width: compact ? 180 : double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          prefixText: prefix,
          prefixStyle:
              const TextStyle(fontSize: 14, color: Colors.black54),
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 14, color: Colors.black26),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRencanaSelector() {
    final List<String> options = ['Harian', 'Mingguan', 'Bulanan'];
    return Row(
      children: options.map((option) {
        final bool selected = _selectedRencana == option;
        return GestureDetector(
          onTap: () => setState(() => _selectedRencana = option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF2E7D32)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4)
                    ]
                  : [],
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}