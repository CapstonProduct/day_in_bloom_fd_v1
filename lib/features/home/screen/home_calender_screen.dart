import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_fd_v1/widgets/calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeCalendarScreen extends StatelessWidget {
  const HomeCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '꽃이 되는 하루'),
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
                        context.go('/homeCalendar/report?date=$formattedDate');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.6,
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                children: [
                  _imgCard('오늘의 할 일\n보러 가기', 'assets/home_icon/flower_icon.png', const Color(0xFFfff6d4), 
                            () {context.go('/homeCalendar/mission');}),
                  _imgCard('데일리\n운동 영상', 'assets/home_icon/green_youtube.png', const Color(0xFFdbf2e6), 
                            () {context.go('/homeCalendar/exvideo');}),
                  _imgCard('맞춤 운동\n추천', 'assets/home_icon/dumbell.png', const Color(0xFFdbf2e6), 
                            () {context.go('/homeCalendar/exerciseRecommendation');}),
                  _imgCard('수면 패턴에\n따른 행동 추천', 'assets/home_icon/pillow.png', const Color(0xFFfff6d4), 
                            () {context.go('/homeCalendar/sleepRecommendation');}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgCard(String title, String imagePath, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
