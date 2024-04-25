import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic> decodeJwt(String token) {
  return JwtDecoder.decode(token);
}
