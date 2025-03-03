import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  static const List<Map<String, dynamic>> notifications = [
    {'text': '환자 김철수님의 건강 리포트가 생성되었습니다.', 'isRead': false, 'createdTime': '2025-01-17 08:00'},
    {'text': '환자 박민수님의 심박수 이상이 감지되었습니다.', 'isRead': false, 'createdTime': '2025-01-17 15:45'},
    {'text': '환자 오지훈님의 건강 리포트가 생성되었습니다.', 'isRead': false, 'createdTime': '2025-01-17 08:10'},
    {'text': '환자 최윤서님의 심박수가 비정상적으로 낮습니다.', 'isRead': false, 'createdTime': '2025-01-17 17:30'},
    {'text': '환자 김철수님의 산소포화도가 낮아졌습니다.', 'isRead': false, 'createdTime': '2025-01-17 18:00'},
    {'text': '환자 이영희님의 혈압이 급격히 상승했습니다. 즉각 확인이 필요합니다.', 'isRead': false, 'createdTime': '2025-01-17 19:20'},
    {'text': '환자 박민수님의 건강 리포트가 생성되었습니다.', 'isRead': false, 'createdTime': '2025-01-17 08:15'},
    {'text': '환자 정하나님의 체온이 정상 범위를 벗어났습니다.', 'isRead': false, 'createdTime': '2025-01-17 20:00'},
    {'text': '환자 김철수님의 건강 리포트가 생성되었습니다.', 'isRead': true, 'createdTime': '2025-01-16 08:00'},
    {'text': '환자 이영희님의 심박수가 높습니다. 안정을 취하도록 안내하세요.', 'isRead': true, 'createdTime': '2025-01-16 09:30'},
    {'text': '환자 박민수님의 혈압이 급격히 상승했습니다. 즉각 확인이 필요합니다.', 'isRead': true, 'createdTime': '2025-01-16 14:20'},
    {'text': '환자 정하나님의 건강 리포트가 생성되었습니다.', 'isRead': true, 'createdTime': '2025-01-16 08:10'},
    {'text': '환자 오지훈님의 심박수 이상이 감지되었습니다.', 'isRead': true, 'createdTime': '2025-01-16 10:45'},
    {'text': '환자 최윤서님의 혈압이 정상 범위를 초과하였습니다.', 'isRead': true, 'createdTime': '2025-01-16 15:30'},
    {'text': '환자 김철수님의 산소포화도가 낮아졌습니다.', 'isRead': true, 'createdTime': '2025-01-16 18:10'},
    {'text': '환자 이영희님의 건강 리포트가 생성되었습니다.', 'isRead': true, 'createdTime': '2025-01-16 08:15'},
    {'text': '환자 박민수님의 체온이 정상 범위를 벗어났습니다.', 'isRead': true, 'createdTime': '2025-01-16 20:30'},
  ];

  String _formatTime(String dateTime) {
    final parsedTime = DateTime.parse(dateTime);
    return DateFormat('MM월 dd일 HH:mm').format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '알림 목록', showBackButton: true),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
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
    );
  }
}
