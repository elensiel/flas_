import 'package:shelf/shelf.dart';

const jsonHeaders = {'content-type': 'application/json'};

extension RequestUser on Request {
  String get userId => context['userId'] as String;
}
