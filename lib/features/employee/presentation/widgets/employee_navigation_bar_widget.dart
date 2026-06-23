import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'profile_card_widget.dart';
import 'search_bar_widget.dart';

class EmployeeNavigationBarWidget extends StatelessWidget {
  const EmployeeNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Card(
        elevation: 10,
        shadowColor: AppColors.lightCardShadowColor,
        color: AppColors.whiteColor,
        margin: EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            children: [
              const SearchBarWidget(),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Ionicons.notifications_outline),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {},
                icon: Icon(Ionicons.help_circle_outline),
              ),
              const SizedBox(width: 20),
              const VerticalDivider(),
              const ProfileCardWidget(),
            ],
          ),
        ),
      ),
    );
  }
}


