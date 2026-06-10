import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'chat_admin_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Apa itu OnlyCats?',
      'answer': 'OnlyCats adalah platform komunitas untuk membantu kucing terlantar. Anda bisa melaporkan penemuan kucing (rescue) atau mencari kucing untuk diadopsi menjadi anggota keluarga baru.',
      'category': 'Umum'
    },
    {
      'question': 'Bagaimana cara melaporkan kucing rescue?',
      'answer': 'Buka menu "Rescue" di navigasi bawah, lalu klik tombol "Ajukan Rescue". Isi data lokasi, kondisi kucing, dan unggah foto terbaru agar admin bisa memverifikasi laporan Anda.',
      'category': 'Rescue'
    },
    {
      'question': 'Apakah adopsi di sini gratis?',
      'answer': 'Ya, 100% gratis. Kami melarang segala bentuk jual beli kucing. Komunitas ini fokus pada kesejahteraan hewan dan pemberian rumah yang layak.',
      'category': 'Adopsi'
    },
    {
      'question': 'Berapa lama proses verifikasi laporan?',
      'answer': 'Tim admin kami biasanya melakukan verifikasi dalam waktu 1-24 jam tergantung antrean laporan yang masuk.',
      'category': 'Rescue'
    },
    {
      'question': 'Cara mengubah data profil saya?',
      'answer': 'Masuk ke menu Profil, pilih ikon "Edit Profil" di bawah foto profil Anda. Anda bisa mengubah nama, bio, dan username di sana.',
      'category': 'Akun'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      return faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F4),
      body: CustomScrollView(
        slivers: [
          // Header Modern
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.orange,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Pusat Bantuan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orange, Color(0xFFFF9E80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Icon(Icons.help_center_rounded, color: Colors.white, size: 50),
                          SizedBox(height: 10),
                          Text(
                            'Ada yang bisa kami bantu?',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar & Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Cari bantuan atau pertanyaan...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.orange),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Pertanyaan Sering Diajukan (FAQ)',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color.fromARGB(255, 105, 44, 3),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // FAQ List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final faq = filteredFaqs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEEEAE8), width: 1),
                    ),
                    child: ExpansionTile(
                      shape: const Border(), // Hilangkan border default
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getIconForCategory(faq['category']!),
                          color: AppColors.orange,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        const Divider(height: 1, color: Color(0xFFF1F1F1)),
                        const SizedBox(height: 12),
                        Text(
                          faq['answer']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredFaqs.length,
              ),
            ),
          ),

          // Footer Contact
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF203554),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masih Bingung?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hubungi tim support kami.',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChatAdminScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Chat Admin'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Rescue': return Icons.sos_rounded;
      case 'Adopsi': return Icons.favorite_rounded;
      case 'Akun': return Icons.person_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

  