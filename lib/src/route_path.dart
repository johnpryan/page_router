import 'package:flutter/widgets.dart';

typedef PageRouterBuilder = Page Function(
    BuildContext context, Map<String, String> parameters);

class RoutePath {
  final PageRouterBuilder builder;
  RoutePath({this.builder});
}