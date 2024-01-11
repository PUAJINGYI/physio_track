import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TranslateService {
  Future<String> translateText(String text, BuildContext context) async {
    String locale = EasyLocalization.of(context)!.currentLocale!.languageCode;
    if (locale == 'en') {
      return text;
    } else {
      String? translatedText;
      final emailAddresses = [
        dotenv.get('EMAIL_ACC1'),
        dotenv.get('EMAIL_ACC2'),
        dotenv.get('EMAIL_ACC3'),
        dotenv.get('EMAIL_ACC4')
      ];
      for (final email in emailAddresses) {
        String urlString = dotenv.get('TRANSLATE_API') +
            Uri.encodeComponent(text) +
            dotenv.get('TRANSLATE_API_LANG') +
            locale +
            dotenv.get('TRANSLATE_EMAIL') +
            email;
        final url = Uri.parse(
          urlString,
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          translatedText = jsonData['responseData']['translatedText'];
          break;
        }
      }

      if (translatedText != null) {
        return translatedText;
      } else {
        throw Exception('Failed to load translation for all email addresses');
      }
    }
  }
}
