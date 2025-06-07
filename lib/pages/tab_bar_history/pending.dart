import 'package:flutter/material.dart';

import '../../widget/tabBar/tab_bar_view.dart';

class PendingTab extends StatelessWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyTabContent(
            title: "UUPS !",
            message: "Belum ada yang ngirim CV ke kamu.",
            image: Icons.insert_drive_file_sharp,
            tabs: [],
          ),
        ],
      ),
    );
  }
}
