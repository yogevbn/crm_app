import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For environment variables

class AIMessageService {
  final String apiUrl =
      "https://api.openai.com/v1/chat/completions"; // API Endpoint

  // Load the API key from environment variables
  final String? apiKey = dotenv.env['OPENAI_API_KEY'];

  AIMessageService() {
    if (apiKey == null) {
      throw Exception("OpenAI API Key is missing!");
    }
  }

  // Method to generate AI messages with a word limit passed inside the prompt
  Future<List<String>> generateAIMessages(
      String prompt, String model, int wordLimit) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Append the word limit instruction to the prompt
    String promptWithLimit =
        "$prompt. Please limit your response to $wordLimit words.";

    final body = jsonEncode({
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              'All responses should be in Hebrew or English as specified by the user.'
        },
        {'role': 'user', 'content': promptWithLimit}
      ],
      'temperature': 0.7,
      'top_p': 1.0,
      'n': 2, // Request 2 responses
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(
            utf8.decode(response.bodyBytes)); // Decode response using UTF-8

        // Extract the assistant's replies from the response
        List<String> messages = (jsonResponse['choices'] as List)
            .map((choice) => choice['message']['content']
                .toString()
                .trim()) // Process the response
            .toList();

        return messages;
      } else {
        throw Exception('Failed to generate messages: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error during API request: $error');
    }
  }
}
