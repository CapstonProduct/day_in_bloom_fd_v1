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
    if (kakaoUserId == null) {
      debugPrint("사용자 ID를 불러올 수 없습니다.");
      setState(() => _isLoading = false);
      return;
    }

    final apiUrl = dotenv.env['NOTIFICATION_LIST_API_URL'];
    if (apiUrl == null || apiUrl.isEmpty) {
      debugPrint(".env에서 NOTIFICATION_LIST_API_URL 설정이 누락됨");
      setState(() => _isLoading = false);
      return;
    }

    final body = {"kakao_user_id": kakaoUserId};
    debugPrint("전송할 데이터:\n${const JsonEncoder.withIndent('  ').convert(body)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("응답 데이터: $decoded");

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> notifications = [];

        decoded.forEach((key, value) {
          final username = value['username'];
          final originalMessage = value['message'];

          final message = '$username 어르신의 $originalMessage';

          notifications.add({
            'text': message,
            'isRead': false,
            'createdTime': value['sent_at'],
          });
        });

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
