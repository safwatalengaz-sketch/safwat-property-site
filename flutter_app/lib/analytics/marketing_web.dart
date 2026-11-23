import 'dart:js_interop';

@JS('safwatMarketing')
external JSObject? get _bridge;

@JS('safwatMarketing.allowed')
external JSBoolean _allowed();

@JS('safwatMarketing.setAllowed')
external void _setAllowed(JSBoolean value);

@JS('safwatMarketing.page')
external void _page(JSString path);

@JS('safwatMarketing.contact')
external void _contact(JSString channel);

bool get available => _bridge != null;
bool get allowed => available && _allowed().toDart;
void setAllowed(bool value) {
  if (available) _setAllowed(value.toJS);
}

void page(String path) {
  if (available) _page(path.toJS);
}

void contact(String channel) {
  if (available) _contact(channel.toJS);
}
