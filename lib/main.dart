import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter_dotenv loads the exact bundle path given here (assets/.env,
  // declared via `assets:` in pubspec.yaml). Using ".env" would throw
  // FileNotFoundError.
  await dotenv.load(fileName: "assets/.env");

  await Supabase.initialize(
    // The .env URL ends with "/", which would produce double-slash paths
    // (e.g. "...co//auth/v1") in the client URLs — strip trailing slashes.
    url: dotenv.env["SUPABASE_API_URL"]!.replaceAll(RegExp(r'/+$'), ''),
    anonKey: dotenv.env["SUPABASE_API_ANON_KEY"]!,
  );

  await initDependencies();

  runApp(const CampusPulseApp());
}
