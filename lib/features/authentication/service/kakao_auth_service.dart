import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KakaoAuthService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> loginWithKakao({required bool autoLogin}) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final user = await UserApi.instance.me();
      final userId = user.id.toString();

      await _storage.write(key: 'access_token', value: token.accessToken);
      await _storage.write(key: 'refresh_token', value: token.refreshToken);
      await _storage.write(key: 'user_id', value: userId);
      await _storage.write(key: 'nickname', value: user.kakaoAccount?.profile?.nickname ?? 'unknown');
      await _storage.write(key: 'auto_login', value: autoLogin.toString());

      final body = {"kakao_user_id": userId, 'login_provider': 'kakao'};
      final url = dotenv.env['KAKAO_LOGIN_API_GATEWAY_URL'];

      final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
      print("전송할 데이터:\n$prettyJson");

      if (url != null && url.isNotEmpty) {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        final decoded = utf8.decode(response.bodyBytes);

        if (response.statusCode == 200) {
          print("람다 전송 성공: $decoded");

          final responseData = jsonDecode(decoded);
          final serverAccessToken = responseData['access_token'];
          final serverUserId = responseData['id'];

          if (serverAccessToken != null) {
            await _storage.write(key: 'server_access_token', value: serverAccessToken);
            print("서버 access_token 저장 완료");
          }
          if (serverUserId != null) {
            await _storage.write(key: 'server_user_id', value: serverUserId.toString());
          }
        } else {
          print("람다 전송 실패: ${response.statusCode} - $decoded");
        }
      } else {
        print(".env에서 KAKAO_LOGIN_API_GATEWAY_URL 설정이 누락됨");
      }

      return body;
    } catch (e) {
      print('카카오 로그인 에러: $e');
      return null;
    }
  }

  static Future<String?> getServerAccessToken() async {
    return await _storage.read(key: 'server_access_token');
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final autoLogin = await _storage.read(key: 'auto_login');
    final token = await _storage.read(key: 'access_token');
    return autoLogin == 'true' && token != null;
  }

  static Future<String?> getNickname() async {
    return await _storage.read(key: 'nickname');
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  static Future<bool> isUserInfoEntered() async {
    final result = await _storage.read(key: 'user_info_entered');
    return result == 'true';
  }

  static Future<void> clearIfNotAutoLogin() async {
    final autoLogin = await _storage.read(key: 'auto_login');
    if (autoLogin != 'true') {
      await logout();
    }
  }

  static Future<bool> checkUserInfoEnteredFromServer() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId == null) return false;

    final url = Uri.parse('https://1dzzkwh851.execute-api.ap-northeast-2.amazonaws.com/Prod/auth/checkUserInfo?kakao_user_id=$userId');
    debugPrint("kakao_user_id: $userId");
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['allEntered'] == true;
      } else {
        print("서버 응답 에러: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("유저 정보 확인 API 호출 실패: $e");
      return false;
      }
  }
}
