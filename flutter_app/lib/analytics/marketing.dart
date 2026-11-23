import 'marketing_stub.dart'
    if (dart.library.js_interop) 'marketing_web.dart'
    as platform;

abstract final class Marketing {
  static bool get available => platform.available;
  static bool get allowed => platform.allowed;
  static void setAllowed(bool value) => platform.setAllowed(value);
  static void page(String path) => platform.page(path);
  static void contact(String channel) => platform.contact(channel);
}
