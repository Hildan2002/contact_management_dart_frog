import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:my_project/di/service_locator.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  await setupServiceLocator();
  
  return serve(handler, ip, port);
}
