import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_router/page_router.dart';
final routes = {
  '/': RoutePath(
    builder: (context, params) =>
        MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('home screen'),
            ),
          ),
        ),
  ),
  '/details': RoutePath(
    builder: (context, params) =>
        MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('details screen'),
            ),
          ),
        ),
  ),
  '/user/:id': RoutePath(
    builder: (context, params) =>
        MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('User ${params[":id"]}'),
            ),
          ),
        ),
  ),
};

void main() {
  testWidgets('basic test', (tester) async {
    var pageRouter = PageRouterData(routes);
    await tester.pumpWidget(_TestApp(pageRouter));
    expect(find.text('home screen'), findsOneWidget);
    pageRouter.pushNamed('/details');
    await tester.pumpAndSettle();
    expect(find.text('details screen'), findsOneWidget);
    pageRouter.pushNamed('/user/123');
    await tester.pumpAndSettle();
    expect(find.text('User 123'), findsOneWidget);
  });

  testWidgets('replaceAllNamed and replaceNamed', (tester) async {
    var pageRouter = PageRouterData(routes);
    await tester.pumpWidget(_TestApp(pageRouter));
    pageRouter.replaceAllNamed(['/', '/details']);
    await tester.pumpAndSettle();
    expect(find.text('details screen'), findsOneWidget);
    pageRouter.pop();
    await tester.pumpAndSettle();
    expect(find.text('home screen'), findsOneWidget);

    pageRouter.replaceNamed('/user/123');
    await tester.pumpAndSettle();
    expect(find.text('User 123'), findsOneWidget);
  });
}

class _TestApp extends StatefulWidget {
  final PageRouterData pageRouterData;

  _TestApp(this.pageRouterData);

  @override
  __TestAppState createState() => __TestAppState();
}

class __TestAppState extends State<_TestApp> {
  @override
  Widget build(BuildContext context) {
    return PageRouter(
      data: widget.pageRouterData,
      child: MaterialApp.router(
        title: 'page_router test app',
        routerDelegate: widget.pageRouterData.routerDelegate,
        routeInformationParser: widget.pageRouterData.informationParser,
      ),
    );
  }
}
