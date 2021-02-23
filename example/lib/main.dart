import 'package:navigator_manager/navigator_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final _routerDelegate = LRouterDelegate(
    pageNotFound: (uri) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Page ${uri.path} not found'),
          ),
        ),
      ),
    ),
    routes: {
      '/': (_) => HomePage(),
      '/test/todo': (uri) =>
          TestPage(uri),
      '/result': (_) => ResultPage(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Uri navigator App',
      routerDelegate: _routerDelegate,
      routeInformationParser: LRouteInformationParser(),
    );
  }
}

class HomePage extends Page {
  HomePage() : super(key: ValueKey('home-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Home();
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Home'),
            TextButton(
              onPressed: () {
                RouteManager.of(context).go(
                    Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
              },
              child: Text('Test toto'),
            ),
            TextButton(
              onPressed: () {
                RouteManager.of(context).go(Uri(path: '/test/12345'));
              },
              child: Text('Test 12345'),
            ),
            TextButton(
              onPressed: () {
                RouteManager.of(context).clearAndGo(Uri(path: '/test/todo'));
              },
              child: Text('Test replace'),
            ),
            TextButton(
              onPressed: () {
                RouteManager.of(context).clearAndMultipleGo([Uri(path: '/test/todo', queryParameters: {'limit': '12'}), Uri(path: '/test/todo')]);
              },
              child: Text('clearAndMultipleGo'),
            ),
            TextButton(
              onPressed: () async{
                print(33333);
                final result = await RouteManager.of(context).waitResultGo(Uri(path: '/result'));
                print(22222);
                print(result);
              },
              child: Text('waitResultGo'),
            ),
            // TextButton(
            //   onPressed: () async{
            //     RouteManager.of(context).insertGo(Uri(path: '/result'));
            //   },
            //   child: Text('insertGo'),
            // ),
          ],
        ),
      ),
    );
  }
}

class TestPage extends Page {
  final Uri uri;

  TestPage(this.uri) : super(key: UniqueKey());

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        final limit =
            int.tryParse(uri.queryParameters['limit'] ?? '-1');
        return Test(
          uri: uri,
          userId: uri.queryParameters['limit'],
          limit: limit,
        );
      },
    );
  }
}

class Test extends StatelessWidget {
  final Uri uri;
  final String userId;
  final int limit;

  const Test({
    Key key,
    @required this.uri,
    @required this.userId,
    @required this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text('test $uri'),
            Text('userId = $userId'),
            Text('limit = $limit'),
            TextButton(
              onPressed: () {
                RouteManager.of(context).goBack(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends Page {
  ResultPage() : super(key: ValueKey('result-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Result();
      },
    );
  }
}

class Result extends StatelessWidget {
  const Result({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Result Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This page shows how to return value from a page',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => RouteManager.of(context).returnResultGo({'uid': 1}),
              child: Text('Result with true via custom method'),
            ),
          ],
        ),
      ),
    );
  }
}