import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';

class ShareService {
  void share(String imgUrl, String txt) async {
    var response = await http.get(Uri.parse(imgUrl));
    Directory tempDir = await getTemporaryDirectory();
    File file = File(join(tempDir.path, 'share-image.png'));
    file.writeAsBytesSync(response.bodyBytes);

    Share.shareFiles([file.path], text: txt);
  }
}
