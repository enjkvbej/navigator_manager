# 简介

A Flutter router based on navigator 2.0 for app and web, provide many useful methods and send params easily.

## 快速开始

在main.dart文件引入路由管理，并进行路由配置

### 初始化路由管理

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _routerDelegate = LRouterDelegate(
    // 配置没有匹配url的页面(app可不配置)
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
    // 配置所有路由信息（必填）
    routes: {
      '/': (uri, params) => HomePage(),
      '/test/todo': (uri, params) =>
          TestPage(uri),
      '/result': (uri, params) => ResultPage(),
      '/login': (uri, params) => LoginPage(),
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
```

其中routes字段：

**key为url**

**value为返回页面的函数, uri是路由参数，params是页面参数，根据参数类型传递**

### 方法

1.`go(Uri uri, {dynamic params})`

路由跳转方法, 支持路由传参和自定义数据类型传参

```dart
RouteManager.go(Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
RouteManager.go(Uri(path: '/test/todo'), params: your model);
```

2.`replace(Uri uri, {dynamic params})`

替换当前路由并跳转

```dart
RouteManager.replace(Uri(path: '/test/todo'));
```

3.`goBack()`

返回上一页, 如若返回传参请用returnResultGo

```dart
RouteManager.goBack();
```

4.`clearAndGo(Uri uri, {dynamic params})`

清空路由栈并重设首页，如登陆场景

```dart
RouteManager.clearAndGo(Uri(path: '/login'));
```

5.`multipleGo(List<Uri> uris, {List<dynamic> params})`

一次设置多个uri并跳转到最后一个路由

```dart
RouteManager.multipleGo([Uri(path: '/test/todo', queryParameters: {'limit': '12'}), Uri(path: '/test/todo')]);
```

6.`clearAndMultipleGo(List<Uri> uris, {List<dynamic> params})`

清空路由栈并跳转(设置多个uri)

```dart
RouteManager.clearAndMultipleGo(Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
```

7.`waitResultGo(Uri uri, {dynamic params})`

跳转等待结果

```dart
RouteManager.waitResultGo(Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
```

8.`returnResultGo(dynamic value)`

跳转返回结果

```dart
RouteManager.returnResultGo(your value);
```

9.`goRoot()`

路由栈只保留首页

```dart
RouteManager.goRoot();
```

10.`removeUri(Uri uri)`

删除指定路由

```dart
RouteManager.removeUri(Uri(path: '/test/todo'));
```

11.`removeLastUri()`

删除栈顶的路由

```dart
RouteManager.removeLastUri();
```

### 页面监听

路由栈变化的监听有两种方式：

```dart
routerDelegate.addListener(() {
  if (routerDelegate.currentConfiguration == Uri(path: '/')) {
    /// to do
  }
}
```

```dart
class APage extends StatefulWidget {
  const APage({Key key}) : super(key: key);

  @override
  _APageState createState() => _APageState();
}

// 3. Add `with RouteAware, RouteObserverMixin` to State and override RouteAware methods.
class _APageState extends State<APage> with RouteAware, RouteObserverMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('A Page'),
        ),
      ),
    );
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() { }

  /// Called when the current route has been pushed.
  @override
  void didPush() { }

  /// Called when the current route has been popped off.
  @override
  void didPop() { }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() { }
}
```

## Todo

1. []升级Flutter v2，支持空安全

2. [x]自定义动画路由

3. []嵌套路由
