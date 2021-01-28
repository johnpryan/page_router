library page_router;

import 'package:flutter/widgets.dart';
import 'package:trie_router/trie_router.dart';
import 'package:path/path.dart' as path;

import 'src/route_data.dart';
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

  void replaceNamed(String routeName) {
    data.replaceNamed(routeName);
  }

  void replaceAllNamed(List<String> routeNames) {
    data.replaceAllNamed(routeNames);
  }

  void pop() {
    data.pop();
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

  void replaceNamed(String routeName) {
    routerDelegate.replaceNamed(routeName);
  }

  void replaceAllNamed(List<String> routeNames) {
    routerDelegate.replaceAllNamed(routeNames);
  }

  void pop() {
    routerDelegate.pop();
  }
}

class PageRouterDelegate extends RouterDelegate<RouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteData> {
  final TrieRouter<RoutePath> trie;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  List<String> _routeStack = ['/'];

  PageRouterDelegate(this.trie) : navigatorKey = GlobalKey<NavigatorState>();

  RouteData get currentConfiguration {
    return RouteData(_routeStack.last);
  }

  Future pushNamed(String name) async {
    if (!await _validate(name)) {
      return;
    }
    _routeStack.add(name);
    notifyListeners();
  }

  Future replaceNamed(String name) async {
    if (!await _validate(name)) {
      return;
    }
    _routeStack.removeLast();
    _routeStack.add(name);
    notifyListeners();
  }

  Future replaceAllNamed(List<String> routeNames) async {
    for (var name in routeNames) {
      if (!await _validate(name)) {
        return;
      }
    }
    _routeStack.clear();
    _routeStack.addAll(routeNames);
    notifyListeners();
  }

  Future pop() async {
    if (!await _validate(_routeStack.last)) {
      return;
    }

    _routeStack.removeLast();
    notifyListeners();
  }

  Future<bool> _validate(String routeName) async {
    var trieData = trie.get(path.split(routeName));
    if (trieData == null) {
      return false;
    }
    var routePath = trieData.value;
    if (routePath.validator == null) {
      return true;
    }
    return await routePath.validator(trieData.parameters);
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
  Future<void> setNewRoutePath(RouteData configuration) async {
    if(!await _validate(configuration.routeString)) {
      return;
    }
    // TODO: allow parent pages to be included
    // Currently, this clears the route stack, which means
    // Any time a new deep link is handled the set of pages is cleared.
    _routeStack
      ..clear()
      ..add(configuration.routeString);
    notifyListeners();
  }
}

class PageRouterInformationParser extends RouteInformationParser<RouteData> {
  final TrieRouter trie;

  PageRouterInformationParser(this.trie);

  @override
  Future<RouteData> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteData(routeInformation.location);
  }

  @override
  RouteInformation restoreRouteInformation(RouteData data) {
    return RouteInformation(location: data.routeString);
  }
}
