import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource_impl.dart';
import 'package:attendance_system_admin/core/models/user_model.dart';
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

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    // Stub the auth getter on SupabaseClient to return our mock GoTrueClient
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    authDatasourceImpl = AuthDatasourceImpl(supabaseClient: mockSupabaseClient);
  });

  group('signUp', () {
    final tUserModel = UserModel(
      id: '',
      email: 'test@example.com',
      name: 'Test User',
      department: 'IT',
      phoneNo: '1234567890',
      userRole: 'Admin',
      organization: 'Test Org',
    );
    const tPassword = 'password123';
    const tUserId = 'user-uuid-123';

    test(
      'should return UserModel when Supabase signUp is successful and user is not null',
      () async {
        // arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();

        when(() => mockUser.id).thenReturn(tUserId);
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        // act
        final result = await authDatasourceImpl.signup(tUserModel, tPassword);

        // assert
        verify(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            password: tPassword,
          ),
        ).called(1);
        
        expect(result.id, tUserId);
        expect(result.email, tUserModel.email);
        expect(result.name, tUserModel.name);
        expect(result.department, tUserModel.department);
        expect(result.phoneNo, tUserModel.phoneNo);
        expect(result.userRole, tUserModel.userRole);
        expect(result.organization, tUserModel.organization);
      },
    );

    test(
      'should throw AuthException when Supabase signUp returns null user',
      () async {
        // arrange
        final mockAuthResponse = MockAuthResponse();
        when(() => mockAuthResponse.user).thenReturn(null);
        when(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            password: tPassword,
          ),
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
              contains('User is null'),
            ),
          ),
        );
        verify(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should throw AuthException when Supabase signUp throws an error',
      () async {
        // arrange
        when(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            password: tPassword,
          ),
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
        verify(
          () => mockGoTrueClient.signUp(
            email: tUserModel.email,
            password: tPassword,
          ),
        ).called(1);
      },
    );
  });
}
