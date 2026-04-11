

import 'package:flutter_math_fork/flutter_math.dart';

class EncoderException implements FlutterMathException {
  @override
  final String message;
  final dynamic token;

  const EncoderException(this.message, [this.token]);

  @override
  String get messageWithType => 'Encoder Exception: $message';
}
