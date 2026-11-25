import 'dart:js_interop';

@JS('safwatMarketing')
external JSObject? get _bridge;

@JS('safwatMarketing.privacyState')
external JSString _privacyState();

@JS('safwatMarketing.showWelcome')
external JSBoolean _showWelcome();

@JS('safwatMarketing.dismissWelcome')
external void _dismissWelcome();

@JS('safwatMarketing.setAllowed')
external void _setAllowed(JSBoolean value);

@JS('safwatMarketing.page')
external void _page(JSString path);

@JS('safwatMarketing.contact')
external void _contact(JSString channel);

bool get available => _bridge != null;
String get privacyState => available ? _privacyState().toDart : 'unavailable';
bool get showWelcome => available && _showWelcome().toDart;
void dismissWelcome() {
  if (available) _dismissWelcome();
}

void setAllowed(bool value) {
  if (available) _setAllowed(value.toJS);
}

void page(String path) {
  if (available) _page(path.toJS);
}

void contact(String channel) {
  if (available) _contact(channel.toJS);
}
