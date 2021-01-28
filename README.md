# page_router

Experimental router for Flutter built using the Navigator 2.0 API.

## Usage

```dart
class _PageRouterExampleState extends State<PageRouterExample> {
  final routerData = PageRouterData({
    '/': RoutePath(
      builder: (context, params) => FadeTransitionPage(
        key: ValueKey('/'),
        child: HomeScreen(),
      ),
    ),
    '/users/:id': RoutePath(
      builder: (context, params) => MaterialPage(
        key: ValueKey('/users/:id'),
        child: UserScreen(userId: params[':id']),
      ),
    ),
    '/users/:id/preferences': RoutePath(
      builder: (context, params) => FadeTransitionPage(
        key: ValueKey('/users/:id/preferences'),
        child: UserPreferencesScreen(
          userId: params[':id'],
        ),
      ),
    ),

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
```


```dart
OutlinedButton(
  child: Text('Go to User 123'),
  onPressed: () {
    PageRouter.of(context).pushNamed('/users/123');
  },
),
```

See the example/ application for a complete example

## Known Issues / Unsupported features

- [ ] Hierarchical Routing (see section below)
- [ ] Displaying subroutes on the same screen
- [ ] Validation
- [ ] replaceNamed, replaceAllNamed, etc.
- [ ] replaceAll(List<String> routes) - replaces the entire stack of pages
- [ ] Including pages on the stack

### Issue: Hierarchical Routing
Right now, this package requires each route to be defined up-front:

```dart
  final routerData = PageRouterData({
    '/': RoutePath(
      builder: (context, params) => FadeTransitionPage(
        key: ValueKey('/'),
        child: HomeScreen(),
      ),
    ),
    '/users/:id': RoutePath(
      builder: (context, params) => MaterialPage(
        key: ValueKey('/users/:id'),
        child: UserScreen(userId: params[':id']),
      ),
    ),
    '/users/:id/preferences': RoutePath(
      builder: (context, params) => FadeTransitionPage(
        key: ValueKey('/users/:id/preferences'),
        child: UserPreferencesScreen(
          userId: params[':id'],
        ),
      ),
    ),
  });
```

Sometimes, parts of the app are built separately, with separate routes. For
example, Team A might define routes for the app, but rely on Team B to define
routes for a part of the app.

To support this use-case, a routing package can add support for hierarchical
routing. For example:

```dart
library app;
import 'team_b.dart';

var routerData = PageRouterData({
  '/': RoutePath(
    builder: (context, params) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('home screen'),
        ),
      ),
    ),
    subroutes: {
      '/teamB': teamBRoutePath,
    },
  ),
});
```

```dart
library team_b;

var teamBRoutePath = RoutePath(
  builder: (context, params) => MaterialPage(
    child: Scaffold(
      body: Center(
        child: Text("Team B's widget"),
      ),
    ),
  ),
  subroutes: {
    '/details': RoutePath(
      builder: (context, params, child) {
        return MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('details screen'),
            ),
          ),
        );
      },
    ),
  },
);

```

The entrypoint for an app needs to decide how to structure the subroutes for an
app, but leaves the underlying route structure to the library / package being
imported.

### Issue: Displaying subroutes on the same screen

Some apps may need to display the child. In this example, both the "My App" Text
widget and the "Details" Text widget are displayed in the Column when the app
navigates to `'/details'`:

```dart
library app;

var routerData = PageRouterData.hierarchical({
  '/': RoutePath(
    childBuilder: (context, params, child) => MaterialPage(
      child: Scaffold(
        body: Column(
          children: [
            Text('My App'),
            child,
          ],
        ),
      ),
    ),
    subroutes: {
      '/details': RoutePath(
        builder: (context, params) {
          return MaterialPage(
            child: Scaffold(
              body: Center(
                child: Text('Details'),
              ),
            ),
          );
        },
      ),
    },
  ),
});
```

### Issue: Validation

Before a route is navigated to, the app may choose to validate that the 
route is valid. For example, checking if a user exists before showing a page:

```dart
var routerData = PageRouterData({
  '/users/:id': RoutePath(
    validator: (params) async {
      // If this is `false`, the route isn't navigated to.
      var exists = await _checkIfUserExists(params[':id']);
      return exists;
    },
    builder: (context, params) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('User ID: ${params[":id"]}'),
        ),
      ),
    ),
  ),
});
```

If the validation failed, a call to
`PageRouter.of(context).pushNamed('/users/123')` will return false, perhaps with
a result object containing a message.

### Issue: Including pages on the stack
Right now, all underlying pages are cleared when a page is navigated to (either
by a linking directly via deep link or but manually updating the URL). 

Instead, RoutePaths should be able to be configured to be included underneath
by adding a flag

```dart
library app;

var routerData = PageRouterData.hierarchical({
  '/': RoutePath(
    // Indicate that this page should be included when any page underneath is
    // routed to.
    includeInPageStack: true, 
    builder: (context, params) {
      return MaterialPage(
        child: Scaffold(
          body: Center(
            child: Text('Details'),
          ),
        ),
      );
    },
  ),
  '/details': RoutePath(
     builder: (context, params) {
       return MaterialPage(
         child: Scaffold(
           body: Center(
             child: Text('Details'),
           ),
         ),
       );
     },
   ),
  ),
});
```
