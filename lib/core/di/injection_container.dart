import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource_impl.dart';
import 'package:attendance_system_admin/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/dashboard/data/datasources/dashboard_datasource_impl.dart';
import 'package:attendance_system_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_alerts_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_attendance_trend_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_department_stats_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_kpis_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:attendance_system_admin/features/students/data/datasources/students_datasource_impl.dart';
import 'package:attendance_system_admin/features/students/data/repositories/students_repository_impl.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/add_student_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_directory_kpis_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_student_attendance_log_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_students_page_usecase.dart';
import 'package:attendance_system_admin/features/students/presentation/bloc/students_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  serviceLocator.registerLazySingleton(() => Supabase.instance.client);

  serviceLocator.registerLazySingleton(
    () => AuthDatasourceImpl(supabaseClient: serviceLocator<SupabaseClient>()),
  );

  serviceLocator.registerLazySingleton(
    () => AuthRepositoryImpl(
      authDatasource: serviceLocator<AuthDatasourceImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => SignupUsecase(authRepository: serviceLocator<AuthRepositoryImpl>()),
  );

  serviceLocator.registerLazySingleton(
    () => LoginUsecase(authRepository: serviceLocator<AuthRepositoryImpl>()),
  );

  serviceLocator.registerLazySingleton(
    () => LogoutUsecase(authRepository: serviceLocator<AuthRepositoryImpl>()),
  );

  serviceLocator.registerFactory(
    () => AuthBloc(
      signupUsecase: serviceLocator<SignupUsecase>(),
      loginUsecase: serviceLocator<LoginUsecase>(),
      logoutUsecase: serviceLocator<LogoutUsecase>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardDatasourceImpl(
      supabaseClient: serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardRepositoryImpl(
      dashboardDatasource: serviceLocator<DashboardDatasourceImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetKpisUsecase(
      dashboardRepository: serviceLocator<DashboardRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetAttendanceTrendUsecase(
      dashboardRepository: serviceLocator<DashboardRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetDepartmentStatsUsecase(
      dashboardRepository: serviceLocator<DashboardRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetAlertsUsecase(
      dashboardRepository: serviceLocator<DashboardRepositoryImpl>(),
    ),
  );

  serviceLocator.registerFactory(
    () => DashboardBloc(
      getKpisUsecase: serviceLocator<GetKpisUsecase>(),
      getAttendanceTrendUsecase: serviceLocator<GetAttendanceTrendUsecase>(),
      getDepartmentStatsUsecase: serviceLocator<GetDepartmentStatsUsecase>(),
      getAlertsUsecase: serviceLocator<GetAlertsUsecase>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => StudentsDatasourceImpl(
      supabaseClient: serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => StudentsRepositoryImpl(
      studentsDatasource: serviceLocator<StudentsDatasourceImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetDirectoryKpisUsecase(
      studentsRepository: serviceLocator<StudentsRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetStudentsPageUsecase(
      studentsRepository: serviceLocator<StudentsRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetStudentAttendanceLogUsecase(
      studentsRepository: serviceLocator<StudentsRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AddStudentUsecase(
      studentsRepository: serviceLocator<StudentsRepositoryImpl>(),
    ),
  );

  serviceLocator.registerFactory(
    () => StudentsBloc(
      getDirectoryKpisUsecase: serviceLocator<GetDirectoryKpisUsecase>(),
      getStudentsPageUsecase: serviceLocator<GetStudentsPageUsecase>(),
      getStudentAttendanceLogUsecase:
          serviceLocator<GetStudentAttendanceLogUsecase>(),
      addStudentUsecase: serviceLocator<AddStudentUsecase>(),
    ),
  );
}
