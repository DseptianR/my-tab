import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'statistik_screen.dart';

// ============================================================
//  TABUNGAN MANUAL SCREEN - TABUNGANKU (Dark Mode Ready)
// ============================================================

/// Data hasil dari halaman manual yang dikembalikan ke StatistikScreen
class ManualResult {
  final int    goalIndex;
  final double deltaAmount; // positif = tambah, negatif = kurang
  final String catatan;

  const ManualResult({
    required this.goalIndex,
    required this.deltaAmount,
    required this.catatan,
  });
}

class TabunganManualScreen extends StatefulWidget {
  /// Daftar goals aktif (In Progress) beserta index aslinya di _goals
  final List<MapEntry<int, SavingGoal>> activeGoals;

  const TabunganManualScreen({super.key, required this.activeGoals});

  @override
  State<TabunganManualScreen> createState() => _TabunganManualScreenState();
}

class _TabunganManualScreenState extends State<TabunganManualScreen> {
  MapEntry<int, SavingGoal>? _selected; // entry yang dipilih
  String  _mode    = '';                // '' | 'tambah' | 'kurang'
  final TextEditingController _nominalController  = TextEditingController();
  final TextEditingController _catatanController  = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // ── DROPDOWN ──────────────────────────────────────────────────
  void _showPilihTabunganSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Pilih Tabungan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                if (widget.activeGoals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Belum ada tabungan aktif.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  )
                else
                  ...widget.activeGoals.map((entry) {
                    final g = entry.value;
                    return ListTile(
                      leading: const Icon(Icons.savings_outlined,
                          color: Color(0xFF4CAF72)),
                      title: Text(g.title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Terkumpul: Rp. ${_fmt(g.collectedAmount)} / Rp. ${_fmt(g.targetAmount)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        setState(() => _selected = entry);
                        Navigator.pop(context);
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── SAVE ──────────────────────────────────────────────────────
  void _onSave() {
    if (_selected == null) {
      _snack('Pilih tabungan terlebih dahulu!', isError: true); return;
    }
    if (_mode.isEmpty) {
      _snack('Pilih Menambah atau Mengurangi!', isError: true); return;
    }
    final String nomStr = _nominalController.text.trim();
    if (nomStr.isEmpty) {
      _snack('Nominal tidak boleh kosong!', isError: true); return;
    }
    final double? nominal = double.tryParse(nomStr);
    if (nominal == null || nominal <= 0) {
      _snack('Nominal harus berupa angka yang valid!', isError: true); return;
    }

    final SavingGoal g        = _selected!.value;
    final double     newTotal = _mode == 'tambah'
        ? g.collectedAmount + nominal
        : g.collectedAmount - nominal;

    if (_mode == 'kurang' && newTotal < 0) {
      _snack('Pengurangan melebihi saldo terkumpul!', isError: true); return;
    }
    if (_mode == 'tambah' && newTotal > g.targetAmount) {
      _snack(
        'Penambahan melebihi target! Maksimal Rp. ${_fmt(g.targetAmount - g.collectedAmount)}',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final double delta   = _mode == 'tambah' ? nominal : -nominal;
    final String catatan = _catatanController.text.trim();

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pop(ManualResult(
      goalIndex:   _selected!.key,
      deltaAmount: delta,
      catatan:     catatan,
    ));
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── BUILD ─────────────────────────────────────────────────────
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
          'Tabungan Manual',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── PILIH TABUNGAN ────────────────────────────
              _buildLabel('Pilih Tabungan'),
              const SizedBox(height: 8),
              _buildDropdownButton(),
              const SizedBox(height: 20),

              // ── TOMBOL TAMBAH / KURANGI ───────────────────
              Row(
                children: [
                  Expanded(child: _buildModeButton('tambah', '+ Menambah')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildModeButton('kurang', '- Mengurangi')),
                ],
              ),
              const SizedBox(height: 20),

              // ── NOMINAL ───────────────────────────────────
              _buildLabel('Nominal'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hint: '',
                prefix: 'Rp. ',
                minLines: 1,
                maxLines: 1,
              ),
              const SizedBox(height: 20),

              // ── CATATAN DESKRIPSI ─────────────────────────
              _buildLabel('Catatan Deskripsi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _catatanController,
                keyboardType: TextInputType.multiline,
                hint: '',
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 40),

              // ── KEMBALI & SAVE ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    label: 'Kembali',
                    outlined: true,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  _buildActionButton(
                    label: 'Save',
                    outlined: false,
                    onTap: _isLoading ? null : _onSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGETS ───────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87));
  }

  Widget _buildDropdownButton() {
    final String label = _selected != null
        ? _selected!.value.title
        : 'Pilih Unit';

    return GestureDetector(
      onTap: _showPilihTabunganSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: _selected != null
                      ? Colors.black87
                      : Colors.black45,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.black54, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, String label) {
    final bool selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? (mode == 'tambah'
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFB71C1C))
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 5)
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
    required String hint,
    required int minLines,
    required int maxLines,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          prefixText: prefix,
          prefixStyle:
              const TextStyle(fontSize: 14, color: Colors.black54),
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 14, color: Colors.black26),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool outlined,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: outlined
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
          boxShadow: !outlined
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: _isLoading && !outlined
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF2E7D32)))
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: outlined ? Colors.white : const Color(0xFF2E7D32),
                ),
              ),
      ),
    );
  }

  String _fmt(double amount) {
    final String raw = amount.toStringAsFixed(0);
    final StringBuffer result = StringBuffer();
    int count = 0;
    for (int i = raw.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(raw[i]);
      count++;
    }
    return result.toString().split('').reversed.join('');
  }
}