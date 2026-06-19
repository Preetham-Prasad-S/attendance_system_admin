import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class FakeSignUpUserEntity extends Fake implements SignUpUserEntity {}

void main() {
  late SignupUsecase signupUsecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeSignUpUserEntity());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signupUsecase = SignupUsecase(authRepository: mockAuthRepository);
  });

  group('SignupUsecase', () {
    final tSignUpUserEntity = SignUpUserEntity(
      id: 'user-id-123',
      name: 'Test Name',
      email: 'test@email.com',
      password: 'password123',
      phoneNumber: '1234567890',
      rememberMe: true,
      organization: 'Test Org',
    );

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: 'test@email.com',
      name: 'Test Name',
      department: null,
      phoneNo: '1234567890',
      userRole: null,
      organization: 'Test Org',
    );

    final tParams = SignupUsecaseParams(signUpUserEntity: tSignUpUserEntity);

    test(
      'should call the signup method on the repository and return Right(UserEntity)',
      () async {
        // arrange
        when(() => mockAuthRepository.signup(any()))
            .thenAnswer((_) async => Right(tUserEntity));

        // act
        final result = await signupUsecase.call(tParams);

        // assert
        verify(() => mockAuthRepository.signup(tSignUpUserEntity)).called(1);
        expect(result, Right(tUserEntity));
      },
    );

    test(
      'should return Left(AuthFailure) when repository signup fails',
      () async {
        // arrange
        final tFailure = AuthFailure(message: 'Signup failed');
        when(() => mockAuthRepository.signup(any()))
            .thenAnswer((_) async => Left(tFailure));

        // act
        final result = await signupUsecase.call(tParams);

        // assert
        verify(() => mockAuthRepository.signup(tSignUpUserEntity)).called(1);
        expect(result, Left(tFailure));
      },
    );
  });
}
