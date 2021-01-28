class RouteData {
  // The pattern used to parse the route string. e.g. "/users/:id"
  final String routeString;

  RouteData(this.routeString);

  @override
  bool operator ==(Object other) =>
      other is RouteData && routeString == other.routeString;

  int get hashCode => routeString.hashCode;

  String toString() => '_RouteData route: $routeString';
}