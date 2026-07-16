import 'package:http/http.dart';

final Client _sharedHttpClient = Client();

Client get httpClient {
  Client client = _sharedHttpClient;
  return client;
}

class GameManager {
  GameManager._internal();
  static final GameManager _instance = GameManager._internal();
  factory GameManager() => _instance;
}
