import 'package:attendance_system_admin/features/employee/presentation/widgets/profile_card_widget.dart';
import 'package:attendance_system_admin/features/profile/data/datasource/profile_datasource_impl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDesktopScreen extends StatelessWidget {
  const ProfileDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final profileDatasource = ProfileDatasourceImpl(
          client: Supabase.instance.client,
        );

        await profileDatasource.signOut();
      },
      child: Text("Sign Out"),
    );
  }
}
