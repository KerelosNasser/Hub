
import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;

  void init() {
    client = Client();
    client
        .setEndpoint('YOUR_APPWRITE_ENDPOINT') // Your Appwrite Endpoint
        .setProject('YOUR_APPWRITE_PROJECT_ID') // Your project ID
        .setSelfSigned(); // For self-signed certificates, only use for development
  }
}