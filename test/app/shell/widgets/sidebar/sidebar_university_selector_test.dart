import 'package:attendance_system_admin/app/shell/widgets/sidebar/sidebar_university_selector.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _apex = Institute(
  id: 'i1',
  slug: 'apex-institute-of-tech',
  name: 'Apex Institute of Tech',
  code: 'Apex',
);
const _northgate = Institute(
  id: 'i2',
  slug: 'northgate-college',
  name: 'Northgate College',
  code: 'NGC',
);
void main() {
  Widget wrap(
    Widget child, {
    required void Function(Institute) onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('super admin', () {
    testWidgets('shows the selected institute and can switch', (tester) async {
      Institute? chosen;

      await tester.pumpWidget(
        wrap(
          SidebarUniversitySelector(
            institutes: const [_apex, _northgate],
            selected: _apex,
            isSuperAdmin: true,
            onChanged: (institute) => chosen = institute,
          ),
          onChanged: (institute) => chosen = institute,
        ),
      );

      expect(find.text('Apex Institute of Tech'), findsOneWidget);
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);

      await tester.tap(find.byType(SidebarUniversitySelector));
      await tester.pumpAndSettle();

      expect(find.text('Northgate College'), findsOneWidget);

      await tester.tap(find.text('Northgate College'));
      await tester.pumpAndSettle();

      expect(chosen, _northgate);
    });

    testWidgets('marks the selected institute with a tick', (tester) async {
      await tester.pumpWidget(
        wrap(
          SidebarUniversitySelector(
            institutes: const [_apex, _northgate],
            selected: _apex,
            isSuperAdmin: true,
            onChanged: (_) {},
          ),
          onChanged: (_) {},
        ),
      );

      await tester.tap(find.byType(SidebarUniversitySelector));
      await tester.pumpAndSettle();

      // One check for the current selection.
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('regular admin', () {
    testWidgets('is locked: no chevron and no dropdown', (tester) async {
      await tester.pumpWidget(
        wrap(
          SidebarUniversitySelector(
            institutes: const [_apex, _northgate],
            selected: _apex,
            isSuperAdmin: false,
            onChanged: (_) {},
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.text('Apex Institute of Tech'), findsOneWidget);
      expect(find.byIcon(Icons.unfold_more), findsNothing);
      // The status dot replaces the chevron.
      expect(find.byType(Container), findsWidgets);

      await tester.tap(find.byType(SidebarUniversitySelector));
      await tester.pumpAndSettle();

      // Nothing opened.
      expect(find.text('Northgate College'), findsNothing);
    });
  });

  testWidgets('falls back to a placeholder when nothing is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SidebarUniversitySelector(
          institutes: const [_apex],
          selected: null,
          isSuperAdmin: true,
          onChanged: (_) {},
        ),
        onChanged: (_) {},
      ),
    );

    expect(find.text('No institute selected'), findsOneWidget);
  });
}