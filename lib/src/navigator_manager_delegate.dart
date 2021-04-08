import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

typedef PageBuilder = Page Function(Uri uri, dynamic params);

/// a [RouterDelegate] based on [Uri]
class LRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();
  RouteManager routeManager;

  LRouterDelegate(
      {@required Map<String, PageBuilder> routes,
      PageBuilder pageNotFound}) {
    routeManager = RouteManager(
      routes: routes,
      pageNotFound: pageNotFound,
    );
    routeManager.addListener(notifyListeners);

    for (final uri in [Uri(path: '/')]) {
      routeManager.go(uri);
    }
  }

  /// get the current route [Uri]
  /// this is show by the browser if your app run in the browser
  Uri get currentConfiguration =>
      routeManager.uris.isNotEmpty ? routeManager.uris.last : null;

  /// add a new [Uri] and the corresponding [Page] on top of the navigator
  @override
  Future<void> setNewRoutePath(Uri uri) => routeManager.go(uri);

  /// @nodoc
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Wrap MaterialApp with RouteObserverProvider.
        RouteObserverProvider(
          create: (context) => GlobalRouteObserver()..navigation.listen(print),
        ),
        ChangeNotifierProvider<RouteManager>(create: (_) => routeManager),
      ],
      child: Consumer<RouteManager>(
        builder: (context, uriRouteManager, _) => Navigator(
          key: navigatorKey,
          pages: [
            for (final page in uriRouteManager.pages) page,
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            if (uriRouteManager.routes.isNotEmpty) {
              uriRouteManager.removeLastUri();
              return true;
            }
            return false;
          },
          observers: [HeroController(), RouteObserverProvider.of(context)],
        ),
      ),
    );
  }
}

/// allow you to interact with the List of [pages]
class RouteManager extends ChangeNotifier {
  static RouteManager of(BuildContext context) =>
      Provider.of<RouteManager>(context, listen: false);

  RouteManager({@required this.routes, @required this.pageNotFound});

  final Map<String, PageBuilder> routes;
  final PageBuilder pageNotFound;

  final _pages = <Page>[];
  final _uris = <Uri>[];

  /// give you a read only access
  /// to the [List] of [Page] you have in your navigator
  List<Page> get pages => UnmodifiableListView(_pages);

  /// give you a read only access
  /// to the [List] of [Uri] you have in your navigator
  List<Uri> get uris => UnmodifiableListView(_uris);
  Completer<dynamic> _boolResultCompleter;

  Future<void> _setNewRoutePath(Uri uri, dynamic params) {
    bool _findRoute = false;
    for (var i = 0; i < routes.keys.length; i++) {
      final key = routes.keys.elementAt(i);
      if (key == uri.path) {
        if (_uris.contains(uri)) {
          final position = _uris.indexOf(uri);
          final _urisLengh = _uris.length;
          for (var start = position; start < _urisLengh - 1; start++) {
            _pages.removeLast();
            _uris.removeLast();
          }
          _findRoute = true;
          break;
        }
        _pages.add(routes[key](uri, params));
        _uris.add(uri);
        _findRoute = true;
        break;
      }
    }
    if (!_findRoute) {
      var page = pageNotFound?.call(uri, params);
      if (page == null) {
        page = MaterialPage(
          child: Scaffold(
            body: Container(
              child: Center(
                child: Text('Page not found'),
              ),
            ),
          ),
        );
      }
      _pages.add(page);
      _uris.add(uri);
    }
    
    notifyListeners();
    
    return SynchronousFuture(null);
  }

  /// goto an [Uri]
  Future<void> go(Uri uri, {dynamic params}) => _setNewRoutePath(uri, params);
  
  /// replace
  Future<void> replace(Uri uri, {dynamic params}) {
    _pages.removeLast();
    _uris.removeLast();
    return go(uri, params: params);
  }

  /// goBack
  void goBack() {
    if (_pages.length > 1) {
      removeLastUri();
    } else {
      print('>>>> 已经是首页，不能再回退了');
    }
  }

  /// clear the list of [pages] and then push an [Uri]
  Future<void> clearAndGo(Uri uri, {dynamic params}) {
    _pages.clear();
    _uris.clear();
    return go(uri, params: params);
  }
  
  /// go multiple [Uri] at once
  Future<void> multipleGo(List<Uri> uris, {List<dynamic> params}) async {
    int index = 0;
    for (final uri in uris) {
      if (params != null && params is List) {
        await go(uri, params: params[index]);
      } else {
        await go(uri);
      }
      index++;
    }
  }

  /// clear the list of [pages] and then push multiple [Uri] at once
  Future<void> clearAndMultipleGo(List<Uri> uris, {List<dynamic> params}) {
    _pages.clear();
    _uris.clear();
    return multipleGo(uris, params: params);
  }

  /// remove a specific [Uri] and the corresponding [Page]
  void removeUri(Uri uri) {
    final index = _uris.indexOf(uri);
    _pages.removeAt(index);
    _uris.removeAt(index);
    notifyListeners();
  }

  /// remove the last [Uri] and the corresponding [Page]
  void removeLastUri() {
    _pages.removeLast();
    _uris.removeLast();
    notifyListeners();
  }

  /// Simple method to use instead of `await Navigator.push(context, ...)`
  /// The result can be set either by [returnWith]
  Future<dynamic> waitResultGo(Uri uri, {dynamic params}) async {
    _boolResultCompleter = Completer<dynamic>();
    await go(uri, params: params);
    notifyListeners();
    return _boolResultCompleter.future;
  }

  /// This is custom method to pass returning value
  /// while popping the page. It can be considered as an example
  void returnResultGo(dynamic value) {
    if (_boolResultCompleter != null) {
      _pages.removeLast();
      _uris.removeLast();
      _boolResultCompleter.complete(value);
      notifyListeners();
    }
  }
 
  /// remove the pages and go root page
  void goRoot() {
    _pages.removeRange(1, _pages.length);
    _uris.removeRange(1, _uris.length);
    notifyListeners();
  }
}
