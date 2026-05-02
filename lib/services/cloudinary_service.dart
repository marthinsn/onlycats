import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dmopwxcar';
  static const String uploadPreset = 'onlycats_rescue_unsigned';

  Future<String> uploadImage(File imageFile, {required String folder}) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload foto gagal: $responseBody');
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    return data['secure_url'] as String;
  }
}
