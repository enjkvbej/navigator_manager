import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigator_manager/navigator_manager.dart';

void main() {
  const MethodChannel channel = MethodChannel('navigator_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NavigatorManager.platformVersion, '42');
  });
}
