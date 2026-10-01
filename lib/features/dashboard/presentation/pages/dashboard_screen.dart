import 'package:flutter/material.dart';

import '../widgets/dashboard_content.dart';
import '../widgets/sidebar/dashboard_sidebar.dart';
import '../widgets/top_bar/dashboard_top_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                const DashboardTopBar(),
                Expanded(child: DashboardContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
