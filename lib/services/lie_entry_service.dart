import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kees/models/lie_entry.dart';

class LieEntryService {
  static const String baseUrl = 'http://127.0.0.1:8000/kees/lie_entries/';

  // Fetch all LieEntries
  static Future<List<LieEntry>> fetchLieEntries() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LieEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load LieEntries');
    }
  }

  // Create a new LieEntry
  static Future<void> createLieEntry(LieEntry entry) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create LieEntry');
    }
  }

  // Update an existing LieEntry
  static Future<void> updateLieEntry(LieEntry entry) async {
    final response = await http.put(
      Uri.parse('$baseUrl${entry.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update LieEntry');
    }
  }

  // Delete a LieEntry by its ID
  static Future<void> deleteLieEntry(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete LieEntry');
    }
  }
}
