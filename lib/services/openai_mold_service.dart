import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tesia_app/models/mold_analysis_result.dart';

class OpenAIMoldService {
  static const String _projectId = 'fir-b4c91';
  static const String _cloudFunctionUrl =
      'https://us-central1-$_projectId.cloudfunctions.net/analyzeMold';

  static Future<MoldAnalysisResult> analyzeMoldImageWithCloudFunction(
    String firebaseImagePath,
    String languageCode,
  ) async {
    try {
      if (!firebaseImagePath.startsWith('http')) {
        throw Exception('Invalid image path: must be a public URL');
      }

      final lang = languageCode ?? 'en';

      final response = await http
          .post(
            Uri.parse(_cloudFunctionUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageUrl': firebaseImagePath, 'lang': lang}),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        throw Exception(
          'Cloud Function error ${response.statusCode}: ${response.body}',
        );
      }

      final jsonResp = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonResp['success'] != true) {
        throw Exception('Cloud Function returned success=false: $jsonResp');
      }

      if (jsonResp['warning'] == 'incomplete_data') {
        final missing = jsonResp['missing'] as Map<String, dynamic>? ?? {};
      }

      Map<String, dynamic> analysisData;

      if (jsonResp['analysis'] != null) {
        analysisData = jsonResp['analysis'] as Map<String, dynamic>;
      } else if (jsonResp['extractedJson'] != null) {
        try {
          analysisData =
              jsonDecode(jsonResp['extractedJson']) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Could not parse analysis: $e');
        }
      } else if (jsonResp['analysisRaw'] != null) {
        throw Exception(
          'Could not extract structured JSON from analysis. Raw: ${jsonResp["analysisRaw"]}',
        );
      } else {
        throw Exception(
          'No analysis data in Cloud Function response: $jsonResp',
        );
      }

 


      return MoldAnalysisResult.fromJson(analysisData);
    } catch (e, st) {
      throw Exception('Failed to analyze image. Please try again later.');
    }
  }
}
