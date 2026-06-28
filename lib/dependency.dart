import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource_impl.dart';
import 'package:attendance_system_admin/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
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

  serviceLocator.registerFactory(
    () => AuthBloc(
      signupUsecase: serviceLocator<SignupUsecase>(),
      loginUsecase: serviceLocator<LoginUsecase>(),
    ),
  );
}
