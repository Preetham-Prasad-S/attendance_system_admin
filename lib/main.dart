import 'package:attendance_system_admin/core/screens/base_screen.dart';
import 'package:attendance_system_admin/dependency.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/auth_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_desktop_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env["SUPABASE_API_URL"]!,
    anonKey: dotenv.env["SUPABASE_API_ANNON_KEY"]!,
  );

  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AuthBloc>(),
      child: MaterialApp(
        title: 'Attendance System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: BaseScreen(),
      ),
    );
  }
}
