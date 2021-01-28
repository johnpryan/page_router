library page_router;

import 'package:flutter/widgets.dart';
import 'package:trie_router/trie_router.dart';
import 'package:path/path.dart' as path;

import 'src/route_path.dart';
export 'src/route_path.dart';

class PageRouter extends InheritedWidget {
  final PageRouterData data;

  const PageRouter({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  static PageRouter of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PageRouter>();
  }

  void pushNamed(String routeName) {
    data.pushNamed(routeName);
  }

  @override
  bool updateShouldNotify(PageRouter old) => data != old.data;
}

class PageRouterData {
  final PageRouterDelegate routerDelegate;
  final PageRouterInformationParser informationParser;

  PageRouterData._(TrieRouter<RoutePath> trieRouter)
      : routerDelegate = PageRouterDelegate(trieRouter),
        informationParser = PageRouterInformationParser(trieRouter);

  factory PageRouterData(Map<String, RoutePath> routes) =>
      PageRouterData._(_createTrieRouter(routes));

  static TrieRouter<RoutePath> _createTrieRouter(
      Map<String, RoutePath> routes) {
    var trie = TrieRouter<RoutePath>();
    for (var key in routes.keys) {
      trie.add(path.split(key), routes[key]);
    }
    return trie;
  }

  void pushNamed(String routeName) {
    routerDelegate.pushNamed(routeName);
  }
}

class _RouteData {
  // The pattern used to parse the route string. e.g. "/users/:id"
  final String routeString;

  _RouteData(this.routeString);

  @override
  bool operator ==(Object other) =>
      other is _RouteData && routeString == other.routeString;

  int get hashCode => routeString.hashCode;

  String toString() => '_RouteData route: $routeString';
}

class PageRouterDelegate extends RouterDelegate<_RouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_RouteData> {
  final TrieRouter<RoutePath> trie;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  List<String> _routeStack = ['/'];

  PageRouterDelegate(this.trie) : navigatorKey = GlobalKey<NavigatorState>();

  _RouteData get currentConfiguration {
    return _RouteData(_routeStack.last);
  }

  void pushNamed(String name) {
    _routeStack.add(name);
    notifyListeners();
  }

  void pop() {
    _routeStack.removeLast();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        ..._routeStack.map((routeName) {
          var trieData = trie.get(path.split(routeName));
          var routePath = trieData.value;
          return routePath.builder(context, trieData.parameters);
        }),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        _routeStack.removeLast();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(_RouteData configuration) async {
    // TODO: allow parent pages to be included
    // Currently, this clears the route stack, which means
    // Any time a new deep link is handled the set of pages is cleared.
    _routeStack
      ..clear()
      ..add(configuration.routeString);
  }
}

class PageRouterInformationParser extends RouteInformationParser<_RouteData> {
  final TrieRouter trie;

  PageRouterInformationParser(this.trie);

  @override
  Future<_RouteData> parseRouteInformation(
      RouteInformation routeInformation) async {
    return _RouteData(routeInformation.location);
  }

  @override
  RouteInformation restoreRouteInformation(_RouteData data) {
    return RouteInformation(location: data.routeString);
  }
}
