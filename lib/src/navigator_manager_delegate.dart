import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef PageBuilder = Page Function(Uri uri);

/// a [RouterDelegate] based on [Uri]
class LRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final List<Uri> initialUris;

  RouteManager routeManager;

  LRouterDelegate(
      {this.initialUris,
      @required Map<String, PageBuilder> routes,
      PageBuilder pageNotFound}) {
    routeManager = RouteManager(
      routes: routes,
      pageNotFound: pageNotFound,
    );
    routeManager.addListener(notifyListeners);

    for (final uri in initialUris ?? [Uri(path: '/')]) {
      routeManager.go(uri);
    }
  }

  
  /// get the current route [Uri]
  /// this is show by the browser if your app run in the browser
  Uri get currentConfiguration =>
      routeManager.uris.isNotEmpty ? routeManager.uris.last : null;

  /// add a new [Uri] and the corresponding [Page] on top of the navigator
  @override
  Future<void> setNewRoutePath(Uri uri) {
    return routeManager.go(uri);
  }

  /// @nodoc
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: routeManager,
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

  Future<void> _setNewRoutePath(Uri uri) {
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
        _pages.add(routes[key](uri));
        _uris.add(uri);
        _findRoute = true;
        break;
      }
    }
    if (!_findRoute) {
      var page = pageNotFound?.call(uri);
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
  Future<void> go(Uri uri) => _setNewRoutePath(uri);
  
  void goBack(BuildContext context) {
    if (_pages.length > 1) {
      Navigator.of(context).pop();
    } else {
      print('>>>> 已经是首页，不能再回退了');
    }
  }

  /// clear the list of [pages] and then push an [Uri]
  Future<void> clearAndGo(Uri uri) {
    _pages.clear();
    _uris.clear();
    return go(uri);
  }
  
  /// go multiple [Uri] at once
  Future<void> multipleGo(List<Uri> uris) async {
    for (final uri in uris) {
      await go(uri);
    }
  }

  /// clear the list of [pages] and then push multiple [Uri] at once
  Future<void> clearAndMultipleGo(List<Uri> uris) {
    _pages.clear();
    _uris.clear();
    return multipleGo(uris);
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
  /// The result can be set either by [returnWith] or by popping the page
  Future<dynamic> waitResultGo(Uri uri) async {
    _boolResultCompleter = Completer<dynamic>();
    await go(uri);
    notifyListeners();
    return _boolResultCompleter.future;
  }

  /// This is custom method to pass returning value
  /// while popping the page. It can be considered as an example
  /// alternative to returning value with `Navigator.pop(context, value)`.
  void returnResultGo(dynamic value) {
    if (_boolResultCompleter != null) {
      _pages.removeLast();
      _uris.removeLast();
      _boolResultCompleter.complete(value);
      notifyListeners();
    }
  }

  // web会有问题
  // void insertGo(Uri uri) {
  //   for (var i = 0; i < routes.keys.length; i++) {
  //     final key = routes.keys.elementAt(i);
  //     if (uri.path == key && _uris.indexOf(uri) == -1) {
  //       _pages.insert(_pages.length-1, routes[key](uri));
  //       _uris.insert(_pages.length-1, uri);
  //       break;
  //     }
  //   }
  //   notifyListeners();
  // }

 
  void goRoot() {
    _pages.removeRange(0, _pages.length - 1);
    _uris.removeRange(0, _uris.length - 1);
    notifyListeners();
  }
}
