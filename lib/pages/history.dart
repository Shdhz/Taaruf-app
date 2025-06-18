import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taaruf_app/pages/tab_bar_history/pending.dart';
import 'package:taaruf_app/pages/tab_bar_history/sent.dart';

import '../widget/bottomnav/bottom_nav.dart';
import '../widget/tabBar/tab_bar_view.dart';

class History extends StatefulWidget {
  const History({super.key});

  static const List<String> tabs = [
    'PENDING',
    'TERKIRIM',
    'DITERIMA',
    'FAVORIT',
  ];

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int initialTabIndex = 0;

  @override
  void initState() {
    super.initState();

    final dynamic arg = Get.arguments?['initialTab'];
    if (arg is int) {
      initialTabIndex = arg.clamp(0, History.tabs.length - 1);
    } else if (arg is String) {
      final index = History.tabs.indexWhere(
        (t) => t.toLowerCase() == arg.toLowerCase(),
      );
      if (index != -1) {
        initialTabIndex = index;
      }
    }

    _tabController = TabController(
      length: History.tabs.length,
      vsync: this,
      initialIndex: initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        title: const Text(
          "History",
          style: TextStyle(color: Colors.deepPurple),
        ),
        bottom: CustomTabBar(controller: _tabController, tabs: History.tabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            History.tabs.map((tab) {
              switch (tab.toUpperCase()) {
                case 'PENDING':
                  return const PendingTab();
                case 'TERKIRIM':
                   return const SentTab();
                case 'DITERIMA':
                  return EmptyTabContent(
                    title: "UUPS !",
                    message: "Belum ada data diterima.",
                    image: Icons.inbox,
                    tabs: [],
                  );
                case 'FAVORIT':
                  return EmptyTabContent(
                    title: "UUPS !",
                    message: "Belum ada data favorit.",
                    image: Icons.favorite_border,
                    tabs: [],
                  );
                default:
                  return const SizedBox(); // fallback jika tab tidak ditemukan
              }
            }).toList(),
      ),

      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
