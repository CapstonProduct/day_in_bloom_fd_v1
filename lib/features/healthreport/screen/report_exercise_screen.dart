import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class ReportExerciseScreen extends StatelessWidget {
  const ReportExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    const Color primaryColor = Color(0xFF41af7a); 

    return Scaffold(
      appBar: const CustomAppBar(title: "건강 리포트"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
                child: const Text(
                  "운동 분석 결과",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/remove_img/exercise_graph_ex.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    buildRowItem("평균 운동 시간", "40 분"),
                    buildRowItem("평균 심박수", "130 bpm"),
                    buildRowItem("에너지 소모량", "264 칼로리"),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedDate,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "어르신의 최근 Fitbit 운동 데이터를 분석한 결과, 평균 일일 걸음 수가 5,000보 이하로 나타났습니다. \n"
                            "심박수 데이터에서는 안정 시 평균 80bpm으로, 약간 높은 경향이 있어 중강도 유산소 운동(예: 빠른 걷기, 실내 사이클)이 권장됩니다. \n"
                            "또한, 활동 중 칼로리 소모량이 적어 근력 운동을 병행하면 대사 건강에 도움이 될 수 있습니다. \n"
                            "꾸준한 운동 습관이 장기적인 건강 유지에 필수적이므로, 하루 30분 이상 지속적인 활동을 권장드립니다.",
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF41af7a), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
