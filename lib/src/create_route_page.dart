
import 'package:flutter/material.dart';

Map<String?, int> _navigatorManagerPageMap = {};
ValueKey createPageKey(String? name) {
  if (_navigatorManagerPageMap[name] != null) {
    _navigatorManagerPageMap[name] = _navigatorManagerPageMap[name]! + 1;
    name = name! + '-${_navigatorManagerPageMap[name]}';
  } else {
    _navigatorManagerPageMap[name] = 0;
    name = name! + '-${_navigatorManagerPageMap[name]}';
  }
  return ValueKey(name);
}

class CreateRoutePage extends Page {
  final String? name;
  final Widget? child;
  final bool maintainState;
  final bool fullscreenDialog;
  final Widget Function(Animation<double> animation, Widget child)? transition;
  CreateRoutePage({this.name, this.child, this.maintainState = true, this.fullscreenDialog = false, this.transition}) : super(key: createPageKey(name));

  @override
  Route createRoute(BuildContext context) {
    if (transition != null) {
      return PageRouteBuilder(
        settings: this,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        pageBuilder: (context, animation, secondaryAnimation) => child!,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return transition!(animation, child);
        },
      );
    } else {
      return MaterialPageRoute(
        settings: this,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        builder: (context) {
          return child!;
        },
      );
    }
  }
}