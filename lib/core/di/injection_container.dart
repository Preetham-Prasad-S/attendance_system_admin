import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource_impl.dart';
import 'package:attendance_system_admin/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/complete_password_setup_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/dashboard/data/datasources/dashboard_datasource_impl.dart';
import 'package:attendance_system_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_alerts_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_attendance_trend_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_department_stats_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_kpis_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:attendance_system_admin/features/institutes/data/datasources/institutes_datasource_impl.dart';
import 'package:attendance_system_admin/features/institutes/data/repositories/institutes_repository_impl.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
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

  serviceLocator.registerLazySingleton(
    () => GetSessionUsecase(authRepository: serviceLocator<AuthRepositoryImpl>()),
  );

  serviceLocator.registerLazySingleton(
    () => CompletePasswordSetupUsecase(
      authRepository: serviceLocator<AuthRepositoryImpl>(),
    ),
  );

  serviceLocator.registerFactory(
    () => AuthBloc(
      signupUsecase: serviceLocator<SignupUsecase>(),
      loginUsecase: serviceLocator<LoginUsecase>(),
      logoutUsecase: serviceLocator<LogoutUsecase>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Institutes: registry, the signed-in user's institute selection, and the
  // super-admin management page.
  // ---------------------------------------------------------------------------
  serviceLocator.registerLazySingleton(() => InstituteContext());

  serviceLocator.registerLazySingleton(
    () => InstitutesDatasourceImpl(
      supabaseClient: serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => InstitutesRepositoryImpl(
      institutesDatasource: serviceLocator<InstitutesDatasourceImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetInstitutesUsecase(
      institutesRepository: serviceLocator<InstitutesRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => CreateInstituteUsecase(
      institutesRepository: serviceLocator<InstitutesRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => UpdateInstituteUsecase(
      institutesRepository: serviceLocator<InstitutesRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetInstituteAdminsUsecase(
      institutesRepository: serviceLocator<InstitutesRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AssignAdminToInstituteUsecase(
      institutesRepository: serviceLocator<InstitutesRepositoryImpl>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => InviteInstituteAdminUsecase(
      institutesRepository: serviceLocator<InstitutesRepositoryImpl>(),
    ),
  );

  serviceLocator.registerFactory(
    () => InstitutesBloc(
      getInstitutesUsecase: serviceLocator<GetInstitutesUsecase>(),
      createInstituteUsecase: serviceLocator<CreateInstituteUsecase>(),
      updateInstituteUsecase: serviceLocator<UpdateInstituteUsecase>(),
      getInstituteAdminsUsecase: serviceLocator<GetInstituteAdminsUsecase>(),
      assignAdminToInstituteUsecase:
          serviceLocator<AssignAdminToInstituteUsecase>(),
      inviteInstituteAdminUsecase:
          serviceLocator<InviteInstituteAdminUsecase>(),
      instituteContext: serviceLocator<InstituteContext>(),
    ),
  );

  serviceLocator.registerFactory(
    () => SessionCubit(
      getSessionUsecase: serviceLocator<GetSessionUsecase>(),
      getInstitutesUsecase: serviceLocator<GetInstitutesUsecase>(),
      instituteContext: serviceLocator<InstituteContext>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardDatasourceImpl(
      supabaseClient: serviceLocator<SupabaseClient>(),
      instituteContext: serviceLocator<InstituteContext>(),
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
      instituteContext: serviceLocator<InstituteContext>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => StudentsDatasourceImpl(
      supabaseClient: serviceLocator<SupabaseClient>(),
      instituteContext: serviceLocator<InstituteContext>(),
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
      instituteContext: serviceLocator<InstituteContext>(),
    ),
  );
}
