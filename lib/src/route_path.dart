import 'package:flutter/widgets.dart';

typedef PageRouterBuilder = Page Function(
    BuildContext context, Map<String, String> parameters);

typedef Validator = Future<bool> Function(Map<String, String> parameters);

class RoutePath {
  final PageRouterBuilder builder;
  final Validator validator;
  final Map<String, RoutePath> subroutes;

  RoutePath({
    this.builder,
    this.validator,
    this.subroutes,
  });
}
