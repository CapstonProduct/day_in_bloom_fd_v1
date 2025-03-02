import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  static const List<Map<String, dynamic>> notifications = [
    {'text': '1월 17일 건강 리포트가 생성되었습니다!', 'isRead': false, 'createdTime': '2025-01-17 08:00'},
    {'text': '주무실 시간입니다. 오늘 하루 수고하셨습니다!', 'isRead': false, 'createdTime': '2025-01-17 22:00'},
    {'text': '저녁 식사를 하실 시간입니다!', 'isRead': false, 'createdTime': '2025-01-17 18:30'},
    {'text': '점심 식사를 하실 시간입니다!', 'isRead': false, 'createdTime': '2025-01-17 12:30'},
    {'text': '아침 식사를 하실 시간입니다!', 'isRead': false, 'createdTime': '2025-01-17 07:30'},
    {'text': '심박수에서 이상이 감지되었습니다.', 'isRead': false, 'createdTime': '2025-01-17 15:45'},
    {'text': '일어서기 목표를 달성했습니다!', 'isRead': true, 'createdTime': '2025-01-16 14:00'},
    {'text': '일어 설 시간입니다. 몸을 일분 동안 움직이세요!', 'isRead': true, 'createdTime': '2025-01-16 10:15'},
    {'text': '심박수가 높습니다. 안정을 취하세요!', 'isRead': true, 'createdTime': '2025-01-16 09:30'},
    {'text': '1월 16일 건강 리포트가 생성되었습니다!', 'isRead': true, 'createdTime': '2025-01-16 08:00'},
    {'text': '주무실 시간입니다. 오늘 하루 수고하셨습니다!', 'isRead': true, 'createdTime': '2025-01-16 22:00'},
    {'text': '저녁 식사를 하실 시간입니다!', 'isRead': true, 'createdTime': '2025-01-16 18:30'},
    {'text': '점심 식사를 하실 시간입니다!', 'isRead': true, 'createdTime': '2025-01-16 12:30'},
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
