import 'package:attendance_system_admin/core/models/user_model.dart';
import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

void main() {
  late AuthDatasourceImpl authDatasourceImpl;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUpAll(() {
    registerFallbackValue(OtpChannel.sms);
    registerFallbackValue(SignOutScope.local);
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    // Stub the auth getter on SupabaseClient to return our mock GoTrueClient
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    authDatasourceImpl = AuthDatasourceImpl(supabaseClient: mockSupabaseClient);
  });

  /// All named parameters of gotrue's signUp must be stubbed, otherwise the
  /// actual call (which fills in defaults like `channel`) won't match.
  When<Future<AuthResponse>> whenSignUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return when(
      () => mockGoTrueClient.signUp(
        email: email,
        phone: any(named: 'phone'),
        password: password,
        emailRedirectTo: any(named: 'emailRedirectTo'),
        data: data ?? any(named: 'data'),
        captchaToken: any(named: 'captchaToken'),
        channel: any(named: 'channel'),
      ),
    );
  }

  group('signUp', () {
    final tUserModel = UserModel(
      id: '',
      email: 'test@example.com',
      name: 'Test User',
      department: 'IT',
      phoneNo: '1234567890',
      role: 'admin',
      organization: 'Test Org',
    );
    const tPassword = 'password123';
    const tUserId = 'user-uuid-123';

    final tExpectedMetadata = {
      'name': tUserModel.name,
      'department': tUserModel.department,
      'phone_no': tUserModel.phoneNo,
      'organization': tUserModel.organization,
    };

    test(
      'should return UserModel when Supabase signUp is successful and user is not null',
      () async {
        // arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();

        when(() => mockUser.id).thenReturn(tUserId);
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        whenSignUp(
          email: tUserModel.email,
          password: tPassword,
        ).thenAnswer((_) async => mockAuthResponse);

        // act
        final result = await authDatasourceImpl.signup(tUserModel, tPassword);

        // assert
        verify(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            phone: any(named: 'phone'),
            password: tPassword,
            emailRedirectTo: any(named: 'emailRedirectTo'),
            data: tExpectedMetadata,
            captchaToken: any(named: 'captchaToken'),
            channel: any(named: 'channel'),
          ),
        ).called(1);

        expect(result.id, tUserId);
        expect(result.email, tUserModel.email);
        expect(result.name, tUserModel.name);
        expect(result.department, tUserModel.department);
        expect(result.phoneNo, tUserModel.phoneNo);
        expect(result.role, tUserModel.role);
        expect(result.organization, tUserModel.organization);
      },
    );

    test(
      'should throw AuthException when Supabase signUp returns null user',
      () async {
        // arrange
        final mockAuthResponse = MockAuthResponse();
        when(() => mockAuthResponse.user).thenReturn(null);
        whenSignUp(
          email: tUserModel.email,
          password: tPassword,
        ).thenAnswer((_) async => mockAuthResponse);

        // act
        final call = authDatasourceImpl.signup(tUserModel, tPassword);

        // assert
        expect(
          () => call,
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Sign In Failed'),
            ),
          ),
        );
      },
    );

    test(
      'should throw AuthException when Supabase signUp throws an error',
      () async {
        // arrange
        whenSignUp(
          email: tUserModel.email,
          password: tPassword,
        ).thenThrow(const AuthException('Signup failed'));

        // act
        final call = authDatasourceImpl.signup(tUserModel, tPassword);

        // assert
        expect(
          () => call,
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Signup failed'),
            ),
          ),
        );
      },
    );
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    When<Future<AuthResponse>> whenSignIn({
      required String email,
      required String password,
    }) {
      return when(
        () => mockGoTrueClient.signInWithPassword(
          email: email,
          phone: any(named: 'phone'),
          password: password,
          captchaToken: any(named: 'captchaToken'),
        ),
      );
    }

    test(
      'should rethrow AuthException when signInWithPassword fails',
      () async {
        // arrange
        whenSignIn(email: tEmail, password: tPassword).thenThrow(
          AuthApiException(
            'Invalid login credentials',
            statusCode: '400',
            code: 'invalid_credentials',
          ),
        );

        // act
        final call = authDatasourceImpl.login(tEmail, tPassword);

        // assert
        expect(
          () => call,
          throwsA(
            isA<AuthApiException>().having(
              (e) => e.code,
              'code',
              'invalid_credentials',
            ),
          ),
        );
      },
    );

    test('should wrap non-auth errors into an AuthException', () async {
      // arrange
      whenSignIn(
        email: tEmail,
        password: tPassword,
      ).thenThrow(Exception('boom'));

      // act
      final call = authDatasourceImpl.login(tEmail, tPassword);

      // assert
      expect(
        () => call,
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('boom'),
          ),
        ),
      );
    });

    test(
      'should throw AuthException when signInWithPassword returns null user',
      () async {
        // arrange
        final mockAuthResponse = MockAuthResponse();
        when(() => mockAuthResponse.user).thenReturn(null);
        whenSignIn(
          email: tEmail,
          password: tPassword,
        ).thenAnswer((_) async => mockAuthResponse);

        // act
        final call = authDatasourceImpl.login(tEmail, tPassword);

        // assert
        expect(
          () => call,
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Login Failed'),
            ),
          ),
        );
      },
    );
  });

  group('logout', () {
    test('should call signOut on the Supabase auth client', () async {
      // arrange
      when(
        () => mockGoTrueClient.signOut(scope: any(named: 'scope')),
      ).thenAnswer((_) async {});

      // act
      await authDatasourceImpl.logout();

      // assert
      verify(
        () => mockGoTrueClient.signOut(scope: any(named: 'scope')),
      ).called(1);
    });
  });
}
