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
      '/': (_, __) => HomePage(),
      '/test/todo': (uri, _) =>
          TestPage(uri),
      '/result': (_, __) => ResultPage(),
      '/login': (_, params) => LoginPage(params),
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
        title: Text('Home Page'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                // 跳转
                RouteManager.of(context).go(
                    Uri(path: '/test/todo', queryParameters: {'text': '12'}));
              },
              child: Text('Test go'),
            ),
            TextButton(
              onPressed: () {
                // 跳转无匹配路由
                RouteManager.of(context).go(Uri(path: '/test/haha'));
              },
              child: Text('Test not found'),
            ),
            TextButton(
              onPressed: () {
                // 清除路由栈并跳转
                RouteManager.of(context).clearAndGo(Uri(path: '/login'), params: UserInfo(name: 'your name', age: 18));
              },
              child: Text('Test clearAndGo'),
            ),
            TextButton(
              onPressed: () {
                // 清除路由栈并跳转（设置多个路由）
                RouteManager.of(context).clearAndMultipleGo([Uri(path: '/test/todo', queryParameters: {'text': '12'}), Uri(path: '/test/todo')]);
              },
              child: Text('clearAndMultipleGo'),
            ),
            TextButton(
              onPressed: () async{
                // 等待结果跳转 配合returnResultGo使用
                final result = await RouteManager.of(context).waitResultGo(Uri(path: '/result'));
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

class TestPage extends Page {
  final Uri uri;

  TestPage(this.uri) : super(key: UniqueKey());

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Test(
          uri: uri,
          text: uri.queryParameters['text'],
        );
      },
    );
  }
}

class Test extends StatelessWidget {
  final Uri uri;
  final String text;

  const Test({
    Key key,
    @required this.uri,
    @required this.text,
  }) : super(key: key);

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
            Text('test $uri'),
            Text('text = $text'),
            TextButton(
              onPressed: () {
                // 返回
                RouteManager.of(context).goBack();
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
        title: Text('Result Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              // 返回结果
              onPressed: () => RouteManager.of(context).returnResultGo({'uid': 1}),
              child: Text('只有调用returnResultGo才带有参数, 默认返回不带参数'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfo {
  final String name;
  final int age;
  UserInfo({this.name, this.age});
}
class LoginPage extends Page {
  final UserInfo userInfo;
  LoginPage(this.userInfo) : super(key: ValueKey('login-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Login(this.userInfo);
      },
    );
  }
}

class Login extends StatelessWidget {
  final UserInfo userInfo;
  const Login(this.userInfo, {Key key}) : super(key: key);

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
              onPressed: () => RouteManager.of(context).replace(Uri(path: '/')),
              child: Text('登陆'),
            ),
          ],
        ),
      ),
    );
  }
}