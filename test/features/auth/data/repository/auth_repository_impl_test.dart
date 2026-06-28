import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/core/models/user_model.dart';
import 'package:attendance_system_admin/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('signup', () {
    final tSignUpUserEntity = SignUpUserEntity(
      id: 'user-id-123',
      name: 'Test Name',
      email: 'test@email.com',
      password: 'password123',
      phoneNumber: 1234567890,
      rememberMe: true,
      organization: 'Test Org',
    );

    final tUserModel = UserModel(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: 1234567890,
      userRole: null,
      organization: 'Test Org',
    );

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: 1234567890,
      userRole: null,
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
        expect(resultUser.userRole, tUserEntity.userRole);
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
  });
}
