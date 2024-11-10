import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendWhatsAppMessage(String phoneNumber, String message) async {
  const String whatsappAPIUrl =
      'https://graph.facebook.com/v20.0/456905560840275/messages';
  const String token =
      '5d4cc89468beca88c1e21c45daa9c534'; // Add your token here

  final response = await http.post(
    Uri.parse(whatsappAPIUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'recipient_type': 'individual',
      'to': phoneNumber,
      'type': 'text',
      'text': {
        'body': message,
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Message sent successfully');
  } else {
    print('Failed to send message: ${response.statusCode}');
  }
}
