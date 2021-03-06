import 'package:navigator_manager/navigator_manager.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _routerDelegate = LRouterDelegate(
    // 配置web用的路由没有匹配的页面 app正常情况下无需
    pageNotFound: (uri, params) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Page ${uri.path} not found'),
          ),
        ),
      ),
    ),
    // 配置所有路由信息
    routes: {
      '/': (_, __) => CreateRoutePage(name: 'home', child: Home()),
      '/test/todo': (uri, _) => CreateRoutePage(
        name: 'test', 
        child: Test(uri: uri, text: uri.queryParameters['text'],), 
        transition: (animation, child) => ScaleTransition(
          alignment: Alignment.bottomLeft,
          scale: Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        )
      ),
      '/result': (_, __) => CreateRoutePage(name: 'result', child: Result()),
      '/login': (_, params) => CreateRoutePage(name: 'login', child: Login(params)),
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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                // 跳转
                RouteManager.go(
                    Uri(path: '/test/todo', queryParameters: {'text': '12'}));
              },
              child: Text('Test go'),
            ),
            TextButton(
              onPressed: () {
                // 跳转无匹配路由
                RouteManager.go(Uri(path: '/test/haha'));
              },
              child: Text('Test not found'),
            ),
            TextButton(
              onPressed: () {
                // 清除路由栈并跳转
                RouteManager.clearAndGo(Uri(path: '/login'), params: UserInfo(name: 'your name', age: 18));
              },
              child: Text('Test clearAndGo'),
            ),
            TextButton(
              onPressed: () {
                // 清除路由栈并跳转（设置多个路由）
                RouteManager.clearAndMultipleGo([Uri(path: '/test/todo', queryParameters: {'text': '12'}), Uri(path: '/test/todo')]);
              },
              child: Text('clearAndMultipleGo'),
            ),
            TextButton(
              onPressed: () async{
                // 等待结果跳转 配合returnResultGo使用
                final result = await RouteManager.waitResultGo(Uri(path: '/result'));
                print(result);
              },
              child: Text('waitResultGo'),
            ),
          ],
        ),
      ),
    );
  }
}

class Test extends StatefulWidget {
  final uri;
  final text;
  Test({
    this.uri,
    this.text, 
    Key? key,
  }) : super(key: key);

  @override
  _TestState createState() => _TestState();
}


class _TestState extends State<Test> with RouteAware, RouteObserverMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text('test ${widget.uri}'),
            Text('text = ${widget.text}'),
            TextButton(
              onPressed: () {
                // 返回
                RouteManager.goBack();
              },
              child: Text('Back'),
            ),
            TextButton(
              onPressed: () {
                // 返回
                RouteManager.go(
                    Uri(path: '/test/todo', queryParameters: {'text': '10'}));
              },
              child: Text('goText'),
            ),
          ],
        ),
      ),
    );
  }
  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    print('didpopnext');
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    print('didpush');
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    print('didpop');
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    print('didpushnext');
  }
}


class Result extends StatelessWidget {
  const Result({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              // 返回结果
              onPressed: () => RouteManager.returnResultGo({'uid': 1}),
              child: Text('只有调用returnResultGo才带有参数, 默认返回不带参数'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfo {
  final String? name;
  final int? age;
  UserInfo({this.name, this.age});
}

class Login extends StatelessWidget {
  final UserInfo userInfo;
  const Login(this.userInfo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${userInfo.name}'),
            Text('${userInfo.age}'),
            TextButton(
              // 返回结果
              onPressed: () => RouteManager.go(Uri(path: '/login'), params: UserInfo(name: 'your name', age: 20)),
              child: Text('登陆'),
            ),
          ],
        ),
      ),
    );
  }
}