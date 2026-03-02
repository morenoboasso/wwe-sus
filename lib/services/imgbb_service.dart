import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ImgBBService {
  const ImgBBService({this.apiKey = _defaultKey});

  final String apiKey;
  static const String _defaultKey = 'ee0dfb194ff42457c3fc57a3aac51722';

  Future<String?> uploadImage(File file) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final request = http.MultipartRequest('POST', uri)
      ..fields['image'] = base64Image
      ..fields['name'] = file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'profile';

    final response = await request.send();
    if (response.statusCode != 200) return null;
    final body = await response.stream.bytesToString();
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    return data?['url'] as String?;
  }
}
