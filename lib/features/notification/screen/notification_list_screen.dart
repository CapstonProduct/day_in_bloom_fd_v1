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
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint(".env에서 ROOT_API_GATEWAY_URL 설정이 누락됨");
      if (mounted) setState(() => _isLoading = false);
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

      if (!mounted) return; 

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        final List<Map<String, dynamic>> notifications = [];
        
        if (responseData is Map<String, dynamic>) {
          final String username = responseData['username'] ?? '알 수 없음';
          final List<dynamic> userNotifications = responseData['notifications'] ?? [];

          for (var notification in userNotifications) {
            final notificationId = notification['id'];
            
            notifications.add({
              'id': notificationId,
              'text': '${notification['message']}',
              'isRead': notification['is_read'] == true || notification['is_read'] == 1,
              'createdTime': notification['sent_at'] ?? '',
              'username': username,
            });
            
            if (notificationId == null) {
              debugPrint('WARNING: Notification missing ID: $notification');
            }
          }
        } else if (responseData is List) {
          for (var userData in responseData) {
            final String username = userData['username'] ?? '알 수 없음';
            final List<dynamic> userNotifications = userData['notifications'] ?? [];

            for (var notification in userNotifications) {
              final notificationId = notification['id'] ?? notification['notification_id'];
              
              notifications.add({
                'id': notificationId,
                'text': '${notification['message']}',
                'isRead': notification['is_read'] == true || notification['is_read'] == 1,
                'createdTime': notification['sent_at'] ?? '',
                'username': username,
              });
              
              if (notificationId == null) {
                debugPrint('WARNING: Notification missing ID: $notification');
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _notifications = notifications;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          debugPrint("응답 실패: ${response.statusCode} - ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버 응답 오류: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("네트워크 요청 실패: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네트워크 오류 발생: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    if (kakaoUserId == null) return;

    final baseUrl = dotenv.env['ROOT_API_GATEWAY_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint(".env에서 ROOT_API_GATEWAY_URL 설정이 누락됨");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://1dzzkwh851.execute-api.ap-northeast-2.amazonaws.com/Prod/change-is-read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'kakaoUserId': kakaoUserId,
          'notificationId': notificationId,
        }),
      );

      if (!mounted) return; // API 응답 후 mounted 체크

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _notifications[index]['isRead'] = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림을 읽음으로 처리했습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('Mark as read failed. Status: ${response.statusCode}, Body: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('알림 읽음 처리 실패')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _markAsRead: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    }
  }

  String _formatTime(String dateTime) {
    try {
      final parsedTime = DateTime.parse(dateTime);
      return DateFormat('yyyy년 MM월 dd일 HH:mm').format(parsedTime);
    } catch (e) {
      debugPrint('Error parsing date: $dateTime, Error: $e');
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '알림 목록', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    '알림이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: Colors.green,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['isRead'] == true;
                      final notificationId = notification['id'];

                      return GestureDetector(
                        onTap: () async {
                          debugPrint('=== 알림 클릭됨 ===');
                          debugPrint('notification 전체 데이터: $notification');
                          debugPrint('isRead: $isRead');
                          debugPrint('notificationId: $notificationId');
                          
                          if (notificationId != null && !isRead) {
                            debugPrint('notificationId가 존재함. API 호출 시작...');
                            await _markAsRead(notificationId, index);
                          } else if (notificationId == null) {
                            debugPrint('ERROR: notificationId가 null입니다!');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('알림 ID를 찾을 수 없습니다. 서버 응답을 확인해주세요.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.grey[200] : Colors.yellow[100],
                            border: const Border(
                              bottom: BorderSide(color: Colors.grey, width: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['text'] ?? '메시지가 없습니다',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(notification['createdTime'] ?? ''),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (notificationId == null) 
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '알림 ID 누락 - 서버 응답 확인 필요',
                                    style: TextStyle(
                                      fontSize: 10, 
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}