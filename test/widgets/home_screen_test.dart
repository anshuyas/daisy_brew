import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daisy_brew/features/dashboard/presentation/pages/home_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/providers/tea_provider.dart';
import 'package:daisy_brew/features/dashboard/data/models/tea_hive_model.dart';
import 'package:daisy_brew/core/services/connectivity/network_info.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

class FakeDioAdapter extends Mock implements HttpClientAdapter {}

final fakeTeaProducts = [
  TeaHiveModel(
    id: 'tea1',
    name: 'Green Tea',
    price: 120,
    image: '',
    category: 'Tea',
    isAvailable: true,
  ),
  TeaHiveModel(
    id: 'tea2',
    name: 'Black Tea',
    price: 130,
    image: '',
    category: 'Tea',
    isAvailable: true,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(ResponseBody.fromString('[]', 200));
  });

  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  });

  Widget makeTestableWidget({List<TeaHiveModel>? teas}) {
    final fakeDio = Dio();
    fakeDio.httpClientAdapter = FakeDioAdapter();
    // Make all requests return empty immediately
    when(
      () => (fakeDio.httpClientAdapter as FakeDioAdapter).fetch(
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((invocation) async {
      final options = invocation.positionalArguments[0] as RequestOptions;

      if (options.path.contains('/profile')) {
        // Profile endpoint — return empty object
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      } else {
        // Products endpoint — return empty array
        return ResponseBody.fromString(
          '[]',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
    });

    return ProviderScope(
      overrides: [
        // Override with the INTERFACE provider type
        teaProductsProvider.overrideWith(
          (ref) async => teas ?? fakeTeaProducts,
        ),
      ],
      child: MaterialApp(
        home: HomeScreen(
          token: 'fake_token',
          fullName: 'Test User',
          email: 'test@email.com',
          dio: fakeDio,
        ),
      ),
    );
  }

  testWidgets('HomeScreen shows Tea products', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    await tester.tap(find.text('Tea'));
    // pump twice: once to trigger setState, once to rebuild
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Green Tea'), findsOneWidget);
    expect(find.text('Black Tea'), findsOneWidget);
  });

  testWidgets('HomeScreen search filters products', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    await tester.tap(find.text('Tea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'Green Tea');
    await tester.pump();

    // This avoids matching the TextField itself
    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.text('Green Tea'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.text('Black Tea'),
      ),
      findsNothing,
    );
  });

  testWidgets('HomeScreen shows placeholder when no products', (tester) async {
    await tester.pumpWidget(makeTestableWidget(teas: []));
    await tester.pump();

    await tester.tap(find.text('Tea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No drinks found'), findsOneWidget);
  });
}
