import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taaruf_app/widget/tabBar/tab_bar_view.dart';

class PendingTab extends StatefulWidget {
  const PendingTab({super.key});

  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> pendingMatches = [];

  @override
  void initState() {
    super.initState();
    _loadPendingMatches();
  }

  Future<void> _loadPendingMatches() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('matches')
          .select(
            'id, status, created_at, requester_id, requester:requester_id(full_name, id, assets(file_url, is_primary))',
          )
          .eq('requested_id', user.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        pendingMatches = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat data pending: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pendingMatches.isEmpty) {
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
      itemCount: pendingMatches.length,
      itemBuilder: (context, index) {
        final match = pendingMatches[index];
        final sender = match['requester'];
        final photo = (sender['assets'] as List).firstWhere(
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
              sender['full_name'] ?? 'Tanpa Nama',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Masuk: ${DateTime.parse(match['created_at']).toLocal().toString().substring(0, 10)}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onTap: () {
              //
            },
          ),
        );
      },
    );
  }
}
