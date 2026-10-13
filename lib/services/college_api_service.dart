import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/college_model.dart';

class CollegeApiService {
  static const String baseUrl =
      'https://indian-colleges-list.vercel.app';

  static Future<List<CollegeModel>> searchColleges({
    required String state,
    required String query,
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/api/institutions/search'
          '?state=${Uri.encodeComponent(state)}'
          '&q=${Uri.encodeComponent(query)}'
          '&page=1'
          '&limit=50',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load colleges: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    List results = [];

    if (decoded is List) {
      results = decoded;
    } else if (decoded is Map<String, dynamic>) {
      results = decoded['results'] ?? decoded['data'] ?? decoded['colleges'] ?? [];
    }

    return results
        .map((college) => CollegeModel.fromJson(college is Map<String, dynamic> ? college : {}))
        .toList();
  }
}
