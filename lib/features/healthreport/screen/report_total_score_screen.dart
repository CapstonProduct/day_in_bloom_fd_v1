import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class ReportTotalScoreScreen extends StatelessWidget {
  const ReportTotalScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalScore = 88;
    final List<Map<String, String>> healthData = [
      {'label': '스트레스', 'value': '64'},
      {'label': '운동', 'value': '2시간 30분'},
      {'label': '수면', 'value': '4시간'},
    ];

    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: "$elderlyName 어르신 건강 리포트"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "전체 종합 점수",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: totalScore / 100,
                    strokeWidth: 3,
                    backgroundColor: Colors.blue[100],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "$totalScore",
                      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Expanded(
              child: ListView.builder(
                itemCount: healthData.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          healthData[index]['label']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black45),
                        ),
                        Text(
                          healthData[index]['value']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
