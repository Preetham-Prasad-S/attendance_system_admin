import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockSignupUsecase extends Mock implements SignupUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class FakeSignupUsecaseParams extends Fake implements SignupUsecaseParams {}

class FakeLoginUsecaseParams extends Fake implements LoginUsecaseParams {}

void main() {
  late AuthBloc authBloc;
  late MockSignupUsecase mockSignupUsecase;
  late MockLoginUsecase mockLoginUsecase;

  setUpAll(() {
    registerFallbackValue(FakeSignupUsecaseParams());
    registerFallbackValue(FakeLoginUsecaseParams());
  });

  setUp(() {
    mockSignupUsecase = MockSignupUsecase();
    mockLoginUsecase = MockLoginUsecase();

    authBloc = AuthBloc(
      signupUsecase: mockSignupUsecase,
      loginUsecase: mockLoginUsecase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc - Signup', () {
    const tName = 'Test Name';
    const tEmail = 'test@email.com';
    const tPassword = 'password123';
    const tPhoneNumber = 1234567890;
    const tRememberMe = true;
    const tOrganization = 'Test Org';

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: tEmail,
      name: tName,
      department: null,
      phoneNo: tPhoneNumber,
      userRole: null,
      organization: tOrganization,
    );

    final tSignupRequestedEvent = SignupRequested(
      name: tName,
      email: tEmail,
      password: tPassword,
      phoneNumber: tPhoneNumber,
      rememberMe: tRememberMe,
      organization: tOrganization,
    );

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    test(
      'should emit [AuthLoading, AuthSuccess] when signup is successful',
      () async {
        // arrange
        when(
          () => mockSignupUsecase.call(any()),
        ).thenAnswer((_) async => Right(tUserEntity));

        // assert later
        final expected = [
          isA<AuthLoading>(),
          isA<AuthSuccess>().having((state) => state.user, 'user', tUserEntity),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        // act
        authBloc.add(tSignupRequestedEvent);
      },
    );

    test(
      'should emit [AuthLoading, AuthFailureState] when signup fails',
      () async {
        // arrange
        const tErrorMessage = 'Signup failed';
        when(
          () => mockSignupUsecase.call(any()),
        ).thenAnswer((_) async => Left(AuthFailure(message: tErrorMessage)));

        // assert later
        final expected = [
          isA<AuthLoading>(),
          isA<AuthFailureState>().having(
            (state) => state.message,
            'message',
            tErrorMessage,
          ),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        // act
        authBloc.add(tSignupRequestedEvent);
      },
    );
  });
}
