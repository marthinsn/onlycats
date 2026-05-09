import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/cat_service.dart';

class AdminCatFormScreen extends StatefulWidget {
  final CatFirestoreModel? cat; // null = tambah baru, ada isi = edit

  const AdminCatFormScreen({super.key, this.cat});

  @override
  State<AdminCatFormScreen> createState() => _AdminCatFormScreenState();
}

class _AdminCatFormScreenState extends State<AdminCatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CatService _service = CatService();
  bool _loading = false;

  // ── Controllers ────────────────────────────────────────────────────────────
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _age;
  late final TextEditingController _location;
  late final TextEditingController _color;
  late final TextEditingController _weight;
  late final TextEditingController _size;
  late final TextEditingController _description;
  late final TextEditingController _shelterName;
  late final TextEditingController _shelterLocation;
  late final TextEditingController _shelterSince;
  late final TextEditingController _personalityInput;

  // ── State fields ───────────────────────────────────────────────────────────
  String _gender = 'male';
  bool _vaccinated = false;
  bool _sterilized = false;
  bool _available = true;
  List<String> _personalities = [];

  bool get isEdit => widget.cat != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cat;
    _name = TextEditingController(text: c?.name ?? '');
    _breed = TextEditingController(text: c?.breed ?? '');
    _age = TextEditingController(text: c?.age ?? '');
    _location = TextEditingController(text: c?.location ?? '');
    _color = TextEditingController(text: c?.color ?? '');
    _weight = TextEditingController(text: c?.weight ?? '');
    _size = TextEditingController(text: c?.size ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _shelterName = TextEditingController(text: c?.shelterName ?? '');
    _shelterLocation = TextEditingController(text: c?.shelterLocation ?? '');
    _shelterSince = TextEditingController(text: c?.shelterSince ?? '');
    _personalityInput = TextEditingController();

    if (c != null) {
      _gender = c.gender;
      _vaccinated = c.vaccinated;
      _sterilized = c.sterilized;
      _available = c.available;
      _personalities = List.from(c.personalities);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _location.dispose();
    _color.dispose();
    _weight.dispose();
    _size.dispose();
    _description.dispose();
    _shelterName.dispose();
    _shelterLocation.dispose();
    _shelterSince.dispose();
    _personalityInput.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _name.text.trim(),
      'breed': _breed.text.trim(),
      'age': _age.text.trim(),
      'location': _location.text.trim(),
      'gender': _gender,
      'color': _color.text.trim(),
      'weight': _weight.text.trim(),
      'size': _size.text.trim(),
      'description': _description.text.trim(),
      'shelterName': _shelterName.text.trim(),
      'shelterLocation': _shelterLocation.text.trim(),
      'shelterSince': _shelterSince.text.trim(),
      'vaccinated': _vaccinated,
      'sterilized': _sterilized,
      'available': _available,
      'personalities': _personalities,
      'image': '', // URL gambar — bisa dikembangkan dengan image upload
    };

    try {
      if (isEdit) {
        await _service.updateCat(widget.cat!.id, data);
      } else {
        await _service.addCat(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addPersonality() {
    final val = _personalityInput.text.trim();
    if (val.isEmpty || _personalities.contains(val)) return;
    setState(() {
      _personalities.add(val);
      _personalityInput.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isEdit ? 'Edit Kucing' : 'Tambah Kucing',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Form ──
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    _buildSection('Informasi Dasar', [
                      _field(_name, 'Nama Kucing', Icons.pets_rounded),
                      _field(_breed, 'Ras / Breed', Icons.category_outlined),
                      _field(_age, 'Umur (cth: 2 tahun)', Icons.cake_outlined),
                      _field(_location, 'Lokasi', Icons.location_on_outlined),
                      _field(_color, 'Warna', Icons.palette_outlined),
                      _field(
                        _weight,
                        'Berat (cth: 3 kg)',
                        Icons.monitor_weight_outlined,
                      ),
                      _field(
                        _size,
                        'Ukuran (kecil/sedang/besar)',
                        Icons.straighten_outlined,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    _buildSection('Jenis Kelamin', [_buildGenderPicker()]),
                    const SizedBox(height: 16),

                    _buildSection('Kondisi', [
                      _buildToggle(
                        'Vaksinasi',
                        _vaccinated,
                        (v) => setState(() => _vaccinated = v),
                      ),
                      _buildToggle(
                        'Sterilisasi',
                        _sterilized,
                        (v) => setState(() => _sterilized = v),
                      ),
                      _buildToggle(
                        'Tersedia untuk adopsi',
                        _available,
                        (v) => setState(() => _available = v),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    _buildSection('Deskripsi', [
                      _fieldMultiline(
                        _description,
                        'Ceritakan tentang kucing ini...',
                      ),
                    ]),
                    const SizedBox(height: 16),

                    _buildSection('Shelter', [
                      _field(_shelterName, 'Nama Shelter', Icons.home_outlined),
                      _field(
                        _shelterLocation,
                        'Lokasi Shelter',
                        Icons.location_city_outlined,
                      ),
                      _field(
                        _shelterSince,
                        'Di shelter sejak (cth: Jan 2024)',
                        Icons.calendar_today_outlined,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    _buildSection('Kepribadian', [
                      _buildPersonalityInput(),
                      if (_personalities.isNotEmpty) _buildPersonalityChips(),
                    ]),
                    const SizedBox(height: 24),

                    // ── Tombol Simpan ──
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF203554),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isEdit ? 'Simpan Perubahan' : 'Tambah Kucing',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.orange, size: 20),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _fieldMultiline(TextEditingController ctrl, String hint) {
    return TextFormField(
      controller: ctrl,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Row(
      children: ['male', 'female'].map((g) {
        final selected = _gender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: Container(
              margin: EdgeInsets.only(right: g == 'male' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF203554)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    g == 'male' ? Icons.male_rounded : Icons.female_rounded,
                    color: selected ? Colors.white : AppColors.secondaryText,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    g == 'male' ? 'Jantan' : 'Betina',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        value: value,
        activeColor: const Color(0xFF203554),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPersonalityInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _personalityInput,
            decoration: InputDecoration(
              hintText: 'Cth: Ramah, Aktif, Pemalu...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onFieldSubmitted: (_) => _addPersonality(),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _addPersonality,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF203554),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _personalities.map((p) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF203554),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _personalities.remove(p)),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFF203554),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
