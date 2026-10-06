import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/core/models/user_model.dart';
import 'package:attendance_system_admin/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthRepositoryImpl authRepositoryImpl;
  late MockAuthDatasource mockAuthDatasource;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockAuthDatasource = MockAuthDatasource();
    authRepositoryImpl = AuthRepositoryImpl(authDatasource: mockAuthDatasource);
  });

  /// Stubs a throwing [AuthDatasource.login] and returns the mapped failure.
  Future<Failure> loginFailure(Object thrown) async {
    when(() => mockAuthDatasource.login(any(), any())).thenThrow(thrown);

    final result = await authRepositoryImpl.login(
      'test@email.com',
      'password123',
    );

    late Failure failure;
    result.fold((f) => failure = f, (_) => fail('Should not succeed'));
    return failure;
  }

  group('signup', () {
    final tSignUpUserEntity = SignUpUserEntity(
      id: 'user-id-123',
      name: 'Test Name',
      email: 'test@email.com',
      password: 'password123',
      phoneNumber: '1234567890',
      rememberMe: true,
      organization: 'Test Org',
    );

    final tUserModel = UserModel(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: '1234567890',
      role: null,
      organization: 'Test Org',
    );

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: '1234567890',
      role: null,
      organization: 'Test Org',
    );

    test(
      'should return Right(UserEntity) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockAuthDatasource.signup(any(), any()),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await authRepositoryImpl.signup(tSignUpUserEntity);

        // assert
        verify(
          () => mockAuthDatasource.signup(any(), tSignUpUserEntity.password),
        ).called(1);
        expect(result.isRight(), true);

        late UserEntity resultUser;
        result.fold(
          (failure) => fail('Should not fail'),
          (user) => resultUser = user,
        );

        expect(resultUser.id, tUserEntity.id);
        expect(resultUser.email, tUserEntity.email);
        expect(resultUser.name, tUserEntity.name);
        expect(resultUser.department, tUserEntity.department);
        expect(resultUser.phoneNo, tUserEntity.phoneNo);
        expect(resultUser.role, tUserEntity.role);
        expect(resultUser.organization, tUserEntity.organization);
      },
    );

    test(
      'should return Left(AuthFailure) when call to datasource throws an exception',
      () async {
        // arrange
        const errorMessage = 'Something went wrong';
        when(
          () => mockAuthDatasource.signup(any(), any()),
        ).thenThrow(Exception(errorMessage));

        // act
        final result = await authRepositoryImpl.signup(tSignUpUserEntity);

        // assert
        verify(
          () => mockAuthDatasource.signup(any(), tSignUpUserEntity.password),
        ).called(1);
        expect(result.isLeft(), true);

        late Failure resultFailure;
        result.fold(
          (failure) => resultFailure = failure,
          (user) => fail('Should not succeed'),
        );

        expect(resultFailure, isA<AuthFailure>());
        expect(resultFailure.message, contains(errorMessage));
      },
    );

    test(
      'should return a friendly message when the email already exists',
      () async {
        // arrange
        when(() => mockAuthDatasource.signup(any(), any())).thenThrow(
          AuthApiException(
            'User already registered',
            statusCode: '400',
            code: 'email_exists',
          ),
        );

        // act
        final result = await authRepositoryImpl.signup(tSignUpUserEntity);

        // assert
        expect(result.isLeft(), true);
        late Failure resultFailure;
        result.fold(
          (failure) => resultFailure = failure,
          (user) => fail('Should not succeed'),
        );
        expect(
          resultFailure.message,
          'An account with this email already exists.',
        );
        expect((resultFailure as AuthFailure).field, AuthErrorField.email);
      },
    );
  });

  group('login', () {
    final tUserModel = UserModel(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: '1234567890',
      role: 'admin',
      organization: 'Test Org',
    );

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: '1234567890',
      role: 'admin',
      organization: 'Test Org',
    );

    test(
      'should return Right(UserEntity) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockAuthDatasource.login(any(), any()),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await authRepositoryImpl.login(
          tUserEntity.email,
          'password123',
        );

        // assert
        verify(
          () => mockAuthDatasource.login(tUserEntity.email, 'password123'),
        ).called(1);
        expect(result.isRight(), true);

        late UserEntity resultUser;
        result.fold(
          (failure) => fail('Should not fail'),
          (user) => resultUser = user,
        );
        expect(resultUser.id, tUserEntity.id);
        expect(resultUser.email, tUserEntity.email);
      },
    );

    test('should map invalid credentials to a friendly message', () async {
      final failure = await loginFailure(
        AuthApiException(
          'Invalid login credentials',
          statusCode: '400',
          code: 'invalid_credentials',
        ),
      );

      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Incorrect email or password. Please try again.');
      expect((failure as AuthFailure).field, AuthErrorField.password);
    });

    test('should map the empty-body 400 wrong-password response to a friendly '
        'message', () async {
      final failure = await loginFailure(
        AuthUnknownException(
          message:
              'Received an empty response with status code 400, '
              'originalError: instance',
          originalError: 'original error',
        ),
      );

      expect(failure.message, 'Incorrect email or password. Please try again.');
      expect((failure as AuthFailure).field, AuthErrorField.password);
    });

    test('should map network errors to a connectivity message', () async {
      final failure = await loginFailure(
        AuthRetryableFetchException(
          message: 'SocketException: Failed host lookup: supabase.co',
        ),
      );

      expect(
        failure.message,
        'Can\'t reach the server. Check your internet connection and try '
        'again.',
      );
      expect((failure as AuthFailure).field, AuthErrorField.form);
    });

    test('should map unexpected errors to the generic message', () async {
      final failure = await loginFailure(Exception('boom'));

      expect(failure.message, 'Something went wrong. Please try again.');
      expect((failure as AuthFailure).field, AuthErrorField.form);
    });

    test('should map a server-side invalid email to the email field', () async {
      final failure = await loginFailure(
        AuthApiException(
          'Email is invalid',
          statusCode: '400',
          code: 'validation_failed',
        ),
      );

      expect(failure.message, 'Please enter a valid email address.');
      expect((failure as AuthFailure).field, AuthErrorField.email);
    });
  });
}
