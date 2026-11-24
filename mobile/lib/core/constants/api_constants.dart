import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return 'https://kainatledger-api.vanapp.co.id/api/v1';
  }
  return defaultTargetPlatform == TargetPlatform.android
      ? 'https://kainatledger-api.vanapp.co.id/api/v1'
      : 'https://kainatledger-api.vanapp.co.id/api/v1';
}

// For local development only - uncomment to test against localhost
// String get baseUrl {
//   if (kIsWeb) {
//     return 'http://localhost:8000/api/v1';
//   }
//   return defaultTargetPlatform == TargetPlatform.android
//       ? 'http://10.0.2.2:8000/api/v1'
//       : 'http://localhost:8000/api/v1';
// }

const int connectTimeoutMs = 10000;
const int receiveTimeoutMs = 15000;

// Storage keys
const String kAccessToken = 'access_token';
const String kRefreshToken = 'refresh_token';

// Pagination
const int kDefaultPageSize = 20;
