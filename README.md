# 简介

A Flutter router based on navigator 2.0 for app and web, provide many useful methods and send params easily.

## 快速开始

在main.dart文件引入路由管理，并进行路由配置

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

## 方法

1.`go(Uri uri, {dynamic params})`

路由跳转方法, 支持路由传参和自定义数据类型传参

```dart
RouteManager.of(context).go(Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
RouteManager.of(context).go(Uri(path: '/test/todo'), params: your model);
```

2.`replace(Uri uri, {dynamic params})`

替换当前路由并跳转

```dart
RouteManager.of(context).replace(Uri(path: '/test/todo'));
```

3.`goBack()`

返回上一页, 如若返回传参请用returnResultGo

```dart
RouteManager.of(context).goBack();
```

4.`clearAndGo(Uri uri, {dynamic params})`

清空路由栈并重设首页，如登陆场景

```dart
RouteManager.of(context).clearAndGo(Uri(path: '/login'));
```

5.`multipleGo(List<Uri> uris, {List<dynamic> params})`

一次设置多个uri并跳转到最后一个路由

```dart
RouteManager.of(context).multipleGo([Uri(path: '/test/todo', queryParameters: {'limit': '12'}), Uri(path: '/test/todo')]);
```

6.`clearAndMultipleGo(List<Uri> uris, {List<dynamic> params})`

清空路由栈并跳转(设置多个uri)

```dart
RouteManager.of(context).clearAndMultipleGo(Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
```

7.`waitResultGo(Uri uri, {dynamic params})`

跳转等待结果

```dart
RouteManager.of(context).waitResultGo(Uri(path: '/test/todo', queryParameters: {'limit': '12'}));
```

8.`returnResultGo(dynamic value)`

跳转返回结果

```dart
RouteManager.of(context).returnResultGo(your value);
```

9.`goRoot()`

路由栈只保留首页

```dart
RouteManager.of(context).goRoot();
```

10.`removeUri(Uri uri)`

删除指定路由

```dart
RouteManager.of(context).removeUri(Uri(path: '/test/todo'));
```

11.`removeLastUri()`

删除栈顶的路由

```dart
RouteManager.of(context).removeLastUri();
```
