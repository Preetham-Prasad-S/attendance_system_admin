import 'package:attendance_system_admin/core/entities/account_status.dart';
import 'package:attendance_system_admin/features/institutes/data/datasources/institutes_datasource_impl.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const tSlug = 'apex-institute-of-tech';


class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('slugifyInstituteName', () {
    test('lowercases, hyphenates and trims', () {
      expect(
        slugifyInstituteName('Apex Institute of Tech'),
        'apex-institute-of-tech',
      );
      expect(
        slugifyInstituteName('  Northgate  College  '),
        'northgate-college',
      );
      expect(
        slugifyInstituteName('St. Jude Tech University'),
        'st-jude-tech-university',
      );
    });

    test('returns empty for input with no alphanumeric characters', () {
      expect(slugifyInstituteName('!!!'), '');
      expect(slugifyInstituteName('   '), '');
    });
  });

  group('createInstitute validation', () {
    late MockSupabaseClient client;
    late InstitutesDatasourceImpl datasource;

    setUp(() {
      client = MockSupabaseClient();
      datasource = InstitutesDatasourceImpl(
        supabaseClient: client,
      );
    });

    test('rejects a name with no alphanumeric characters', () async {
      await expectLater(
        datasource.createInstitute(const CreateInstituteParams(name: '!!!')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Enter a name'),
          ),
        ),
      );
      verifyNever(() => client.from(any()));
    });
  });

  group('inviteAdmin validation', () {
    late InstitutesDatasourceImpl datasource;

    setUp(() {
      datasource = InstitutesDatasourceImpl(
        supabaseClient: MockSupabaseClient(),
      );
    });

    test('rejects an email without an @ before calling the function', () async {
      await expectLater(
        datasource.inviteAdmin(
          const InviteAdminParams(
            name: 'A Admin',
            email: 'not-an-email',
            instituteSlug: tSlug,
          ),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('valid email'),
          ),
        ),
      );
    });
  });

  group('InstituteAdmin', () {
    test('maps a pending status to invited', () {
      final admin = InstituteAdmin.fromMap(<String, dynamic>{
        'id': 'p1',
        'email': 'a@example.com',
        'name': 'A Admin',
        'status': 'invited',
      });

      expect(admin.status, AccountStatus.invited);
      expect(admin.isPending, isTrue);
    });

    test('defaults an unknown status to invited (fail closed)', () {
      final admin = InstituteAdmin.fromMap(<String, dynamic>{
        'id': 'p2',
        'email': 'b@example.com',
        'name': 'B Admin',
        'status': null,
      });

      expect(admin.status, AccountStatus.invited);
      expect(admin.isPending, isTrue);
    });

    test('maps active', () {
      final admin = InstituteAdmin.fromMap(<String, dynamic>{
        'id': 'p3',
        'email': 'c@example.com',
        'name': 'C Admin',
        'status': 'active',
      });

      expect(admin.status, AccountStatus.active);
      expect(admin.isPending, isFalse);
    });
  });

  group('Institute', () {
    test('fromMap defaults is_active to true and keeps null code', () {
      final parsed = Institute.fromMap(<String, dynamic>{
        'id': 'i9',
        'slug': 'x-y',
        'name': 'X Y',
        'code': null,
      });

      expect(parsed.isActive, isTrue);
      expect(parsed.code, isNull);
    });

    test('equality is by value', () {
      expect(
        Institute.fromMap(<String, dynamic>{
          'id': 'i9',
          'slug': 'x-y',
          'name': 'X Y',
          'code': null,
        }),
        equals(const Institute(id: 'i9', slug: 'x-y', name: 'X Y')),
      );
    });
  });
}