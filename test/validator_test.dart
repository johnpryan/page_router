import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:page_router/page_router.dart';
import 'package:page_router/src/route_data.dart';

void main() {
  group('validator', () {
    testWidgets('can validate', (tester) async {
      var isLoggedIn = false;
      var pageRouter = _createRouter(
        validator: (params) async {
          return isLoggedIn;
        },
      );

      await tester.pumpWidget(_TestApp(pageRouter));
      expect(find.text('home screen'), findsOneWidget);

      pageRouter.pushNamed('/details');
      await tester.pumpAndSettle();
      expect(find.text('home screen'), findsOneWidget);

      isLoggedIn = true;
      pageRouter.pushNamed('/details');
      await tester.pumpAndSettle();
      expect(find.text('details screen'), findsOneWidget);
    });
    testWidgets('can validate asynchronously', (tester) async {
      var isLoggedIn = false;
      var pageRouter = _createRouter(
        validator: (params) async {
          await Future.delayed(Duration(milliseconds: 100));
          return isLoggedIn;
        },
      );

      await tester.pumpWidget(_TestApp(pageRouter));
      expect(find.text('home screen'), findsOneWidget);

      pageRouter.pushNamed('/details');
      await tester.pumpAndSettle();
      expect(find.text('home screen'), findsOneWidget);

      isLoggedIn = true;
      pageRouter.pushNamed('/details');
      await tester.pumpAndSettle();
      expect(find.text('details screen'), findsOneWidget);
    });

    testWidgets('validates when setNewRoutePath is called', (tester) async {
      var isLoggedIn = false;
      var pageRouter = _createRouter(
        validator: (params) async {
          return isLoggedIn;
        },
      );

      await tester.pumpWidget(_TestApp(pageRouter));
      expect(find.text('home screen'), findsOneWidget);

      await pageRouter.routerDelegate.setNewRoutePath(RouteData('/details'));

      await tester.pumpAndSettle();
      expect(find.text('home screen'), findsOneWidget);

      print('setting isLoggedIn to true');
      isLoggedIn = true;
      await pageRouter.routerDelegate.setNewRoutePath(RouteData('/details'));
      await tester.pumpAndSettle();
      expect(find.text('details screen'), findsOneWidget);
    });
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

PageRouterData _createRouter({Validator validator}) {
  return PageRouterData({
    '/': RoutePath(
      builder: (context, params) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: Text('home screen'),
          ),
        ),
      ),
    ),
    '/details': RoutePath(
      validator: validator,
      builder: (context, params) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: Text('details screen'),
          ),
        ),
      ),
    ),
    '/login': RoutePath(
      builder: (context, params) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: TextButton(
              child: Text('login screen'),
              onPressed: () {
                PageRouter.of(context).replaceNamed('/');
              },
            ),
          ),
        ),
      ),
    ),
  });
}
