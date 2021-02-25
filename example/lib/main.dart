import 'package:flutter/material.dart';
import 'package:page_router/page_router.dart';

void main() {
  runApp(PageRouterExample());
}

class PageRouterExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageRouterExampleState();
}

Validator idValidator = (params) async {
  var id = int.tryParse(params[':id']);
  return id != null && id < 100;
};

class _PageRouterExampleState extends State<PageRouterExample> {
  final routerData = PageRouterData({
    '/': RoutePath(
      builder: (context, params) => FadeTransitionPage(
        key: ValueKey('/'),
        child: HomeScreen(),
      ),
    ),
    '/users/:id': RoutePath(
      validator: idValidator,
      builder: (context, params) => MaterialPage(
        key: ValueKey('/users/:id'),
        child: UserScreen(userId: params[':id']),
      ),
      subroutes: {
        'preferences': RoutePath(
          validator: idValidator,
          builder: (context, params) => FadeTransitionPage(
            key: ValueKey('/preferences'),
            child: UserPreferencesScreen(
              userId: params[':id'],
            ),
          ),
        ),
      }
    ),
  });

  @override
  Widget build(BuildContext context) {
    return PageRouter(
      data: routerData,
      child: MaterialApp.router(
        title: 'page_router Example App',
        routerDelegate: routerData.routerDelegate,
        routeInformationParser: routerData.informationParser,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              'Home Page',
              style: Theme.of(context).textTheme.headline3,
            ),
            OutlinedButton(
              child: Text('Go to User 5'),
              onPressed: () {
                PageRouter.of(context).pushNamed('/users/5');
              },
            ),
            OutlinedButton(
              child: Text('Go to User 123 (invalid route)'),
              onPressed: () {
                PageRouter.of(context).pushNamed('/users/123');
              },
            ),
            OutlinedButton(
              child: Text('Push using the Navigator'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            )
          ],
        ),
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  final String userId;

  UserScreen({
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              'User',
              style: Theme.of(context).textTheme.headline3,
            ),
            Text('ID: $userId'),
            OutlinedButton(
              child: Text('Preferences'),
              onPressed: () {
                PageRouter.of(context).pushNamed('/users/$userId/preferences');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserPreferencesScreen extends StatelessWidget {
  final String userId;

  UserPreferencesScreen({
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              'User Preferences',
              style: Theme.of(context).textTheme.headline3,
            ),
            Text('ID $userId'),
          ],
        ),
      ),
    );
  }
}

class FadeTransitionPage extends Page {
  final Widget child;

  FadeTransitionPage({
    Key key,
    this.child,
  }) : super(key: key);

  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
