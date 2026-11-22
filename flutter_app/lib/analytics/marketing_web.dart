import 'dart:js_interop';

@JS('safwatMarketing.hasPreference')
external JSBoolean _hasPreference();

@JS('safwatMarketing.allowed')
external JSBoolean _allowed();

@JS('safwatMarketing.setAllowed')
external void _setAllowed(JSBoolean value);

@JS('safwatMarketing.page')
external void _page(JSString path);

@JS('safwatMarketing.contact')
external void _contact(JSString channel);

bool get available => true;
bool get hasPreference => _hasPreference().toDart;
bool get allowed => _allowed().toDart;
void setAllowed(bool value) => _setAllowed(value.toJS);
void page(String path) => _page(path.toJS);
void contact(String channel) => _contact(channel.toJS);
