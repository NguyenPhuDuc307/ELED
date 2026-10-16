import 'package:web/web.dart' as web;

void downloadJson(String name, String contents) {
  final anchor = web.HTMLAnchorElement()
    ..href =
        'data:application/json;charset=utf-8,${Uri.encodeComponent(contents)}'
    ..download = name;
  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
