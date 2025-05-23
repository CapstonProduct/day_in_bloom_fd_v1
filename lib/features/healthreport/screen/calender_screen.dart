import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/widgets/calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';
    final String encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'] ?? '';

    return Scaffold(
      appBar: CustomAppBar(title: '$elderlyName 어르신 건강 캘린더'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: const Text(
                        '날짜를 클릭하여 그날의 건강 리포트를 확인하세요!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CalendarWidget(
                      onDateSelected: (selectedDate) {
                        String formattedDate = "${selectedDate.year} / ${selectedDate.month.toString().padLeft(2, '0')} / ${selectedDate.day.toString().padLeft(2, '0')}";
                        final now = DateTime.now();
                        final difference = now.difference(selectedDate).inDays;
                        if (difference <= 30) {  // 오늘 날짜로부터 30일 이내
                          context.go('/homeElderlyList/calendar/report?date=$formattedDate&name=$elderlyName&encodedId=$encodedId');
                        } else {  // 오늘 날짜로부터 30일보다 이전
                          context.go('/homeElderlyList/calendar/ago30plusReport?date=$formattedDate&name=$elderlyName&encodedId=$encodedId');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
