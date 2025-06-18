import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taaruf_app/widget/tabBar/tab_bar_view.dart';

class SentTab extends StatefulWidget {
  const SentTab({super.key});

  @override
  State<SentTab> createState() => _SentTabState();
}

class _SentTabState extends State<SentTab> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> sentMatches = [];

  @override
  void initState() {
    super.initState();
    _loadSentMatches();
  }

  Future<void> _loadSentMatches() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('matches')
          .select(r'''
                id,
                status,
                created_at,
                requested_id,
                requested:profiles!matches_requested_id_fkey(
                  full_name,
                  id,
                  assets:assets!user_id(asset_type, file_url, is_primary)
                )
          ''')
          .eq('requester_id', user.id)
          .order('created_at', ascending: false);

      // ignore: unnecessary_null_comparison
      if (response == null) throw Exception('Response null');

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        response,
      );
      debugPrint('[DEBUG] sentMatches raw: $list');

      setState(() {
        sentMatches =
            list.map((m) {
              final req = m['requested'] as Map<String, dynamic>? ?? {};
              return {
                'id': m['id'],
                'status': m['status'],
                'created_at': m['created_at'],
                'requested': {
                  'id': req['id'],
                  'full_name': req['full_name'],
                  'assets': (req['assets'] ?? []) as List<dynamic>,
                },
              };
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal muat sentMatches: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildStatusBadge(String status) {
    final colorMap = {
      'pending': Colors.orange,
      'accepted': Colors.green,
      'rejected': Colors.red,
      'completed': Colors.blue,
      'expired': Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: colorMap[status]?.withOpacity(0.2),
        border: Border.all(color: colorMap[status] ?? Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorMap[status],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sentMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyTabContent(
              title: "UUPS !",
              message: "Belum ada yang ngirim CV ke kamu.",
              image: Icons.insert_drive_file_sharp,
              tabs: const [],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sentMatches.length,
      itemBuilder: (context, index) {
        final match = sentMatches[index];
        final target = match['requested'];
        final photo = (target['assets'] as List).firstWhere(
          (a) => a['is_primary'] == true,
          orElse: () => null,
        );
        final imageUrl = photo?['file_url'];

        return Card(
          color: const Color.fromARGB(255, 250, 250, 250),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage:
                  imageUrl != null
                      ? NetworkImage(imageUrl)
                      : const AssetImage('images/default_picture.jpg')
                          as ImageProvider,
            ),
            title: Text(
              target['full_name'] ?? 'Tanpa Nama',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Dikirim: ${DateTime.parse(match['created_at']).toLocal().toString().substring(0, 10)}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            trailing: _buildStatusBadge(match['status']),
          ),
        );
      },
    );
  }
}
