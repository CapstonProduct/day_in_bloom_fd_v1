import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late Future<Map<String, bool>> _alertPermissions;

  final String rootUrl = dotenv.env['ROOT_API_GATEWAY_URL']!;

  @override
  void initState() {
    super.initState();
    _alertPermissions = fetchAlertPermissions();
  }

  Future<Map<String, bool>> fetchAlertPermissions() async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    final token = await KakaoAuthService.getServerAccessToken();
    if (kakaoUserId == null) throw Exception('사용자 ID를 불러올 수 없습니다.');

    final url = Uri.parse('$rootUrl/$kakaoUserId/alerts'); // ✅ 여기 alerts 붙음!
    debugPrint("요청 URL: $url");

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $token',
    });

    final responseBody = utf8.decode(response.bodyBytes);
    debugPrint("알림 조회 응답:\n$responseBody");

    if (response.statusCode != 200) {
      throw Exception('알림 데이터를 불러오지 못했습니다. 상태코드: ${response.statusCode}');
    }

    final List<dynamic> alerts = jsonDecode(responseBody)['alerts'];

    return {
      for (var alert in alerts)
        _translateAlertType(alert['alert_type']): alert['is_enabled'] == 1,
    };
  }

  Future<void> updateAlert(String alertType, bool isEnabled) async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    final token = await KakaoAuthService.getServerAccessToken();
    
    if (kakaoUserId == null) return;

    final url = Uri.parse('$rootUrl/$kakaoUserId/alerts');
    final body = {
      'alert_type': alertType,
      'is_enabled': isEnabled,
    };

    debugPrint("알림 수정 요청:\n${jsonEncode(body)}");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Basic $token",
      },
      body: jsonEncode(body),
    );

    debugPrint("응답 상태: ${response.statusCode}");
    debugPrint("응답 본문: ${response.body}");
  }

  String _translateAlertType(String type) {
    switch (type) {
      case 'report_ready':
        return '리포트 생성 알림';
      case 'anomaly_alert':
        return '이상 징후 알림';
      case 'device_connect':
        return '기기 연결 알림';
      default:
        return type;
    }
  }

  String _translateToEnum(String display) {
    switch (display) {
      case '리포트 생성 알림':
        return 'report_ready';
      case '이상 징후 알림':
        return 'anomaly_alert';
      case '기기 연결 알림':
        return 'device_connect';
      default:
        return display;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _alertPermissions = fetchAlertPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '알림 설정', showBackButton: true),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.green,
        child: FutureBuilder<Map<String, bool>>(
          future: _alertPermissions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('오류: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터 없음'));
            }

            final permissions = snapshot.data!;
            final keys = permissions.keys.toList();

            return ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final label = keys[index];
                final value = permissions[label]!;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  color: index.isEven ? Colors.grey[200] : Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 16)),
                      Switch(
                        value: value,
                        onChanged: (bool newValue) {
                          final alertType = _translateToEnum(label);
                          setState(() {
                            permissions[label] = newValue;
                          });
                          updateAlert(alertType, newValue);
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
