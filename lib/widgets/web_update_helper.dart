import 'package:flutter/foundation.dart';

// Conditional import: web vs stub
import 'web_update_stub.dart'
    if (dart.library.html) 'web_update_web.dart' as platform;

void reloadPage() => platform.reloadPage();
