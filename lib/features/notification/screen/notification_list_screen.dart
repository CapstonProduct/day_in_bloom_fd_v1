import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);

    final kakaoUserId = await KakaoAuthService.getUserId();
    final serverAccessToken = await KakaoAuthService.getServerAccessToken();

    if (kakaoUserId == null || serverAccessToken == null) {
      debugPrint("사용자 ID 또는 토큰을 불러올 수 없습니다.");
      setState(() => _isLoading = false);
      return;
    }

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint(".env에서 ROOT_API_GATEWAY_URL 설정이 누락됨");
      setState(() => _isLoading = false);
      return;
    }

    final fullUrl = Uri.parse('$baseUrl/$kakaoUserId/notifications');
    debugPrint("요청 URL: $fullUrl");

    try {
      final response = await http.get(
        fullUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $serverAccessToken",
        },
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> notifications = [];
        final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));

        for (var userData in decoded) {
          final String username = userData['username'] ?? '알 수 없음';
          final List<dynamic> userNotifications = userData['notifications'] ?? [];

          for (var notification in userNotifications) {
            notifications.add({
              'text': '$username 어르신의 ${notification['message']}',
              'isRead': notification['is_read'] ?? false,
              'createdTime': notification['sent_at'] ?? '',
            });
          }
        }

        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint("응답 실패: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 응답 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("네트워크 요청 실패: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류 발생: $e')),
      );
    }
  }

  String _formatTime(String dateTime) {
    final parsedTime = DateTime.parse(dateTime);
    return DateFormat('yyyy년 MM월 dd일 HH:mm').format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '알림 목록', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: Colors.green,
              child: ListView.builder(
                itemCount: _notifications.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: notification['isRead'] ? Colors.grey[200] : Colors.yellow[100],
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['text'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification['createdTime']),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
