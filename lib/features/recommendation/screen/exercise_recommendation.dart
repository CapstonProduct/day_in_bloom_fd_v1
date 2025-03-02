import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class ExerciseRecommendationScreen extends StatelessWidget {
  const ExerciseRecommendationScreen({super.key});

  final String username = "최예름";

  final String monthlyExerciseAnalysis = 
      "지난 한 달 동안 하루 평균 걸음 수는 5802보이며, 활동 시간은 73분으로 나타났습니다. "
      "하루 평균 칼로리 소모량은 2055kcal이며, 좌식 시간은 평균 751분으로 기록되었습니다. "
      "평균 심박수는 72bpm으로, 유산소 운동의 빈도를 고려할 필요가 있습니다. "
      "주당 평균 운동 세션은 2.2회로, 규칙적인 운동 습관을 유지하는 것이 중요합니다. "
      "전반적으로 신체 활동량이 적절한지 평가하고, 개선이 필요한 부분을 확인하는 것이 필요합니다.";

  final String yesterdayExerciseAnalysis = 
      "어제 하루 동안 2225보를 걸었으며, 총 79분 동안 활동하였습니다. "
      "어제 소모한 칼로리는 1885kcal이며, 좌식 시간은 870분으로 나타났습니다. "
      "평균 심박수는 80bpm으로, 운동 강도를 조절할 필요가 있습니다. "
      "어제 진행한 운동 세션은 3회였으며, 이는 최근 평균과 비교해 활동량이 증가하였습니다. "
      "일일 목표 대비 활동량을 점검하고, 지속적으로 신체 활동을 유지하는 것이 중요합니다.";

  final String exerciseTips = 
      "활동량을 증가시키기 위해 하루 최소 6000보 이상 걷기를 목표로 설정하는 것이 좋습니다. "
      "좌식 시간이 870분으로 나타났으므로, 중간중간 가벼운 스트레칭이나 짧은 산책을 추가하는 것이 필요합니다. "
      "심박수(80bpm)가 안정적인 범위 내에 있도록 가벼운 유산소 운동을 포함하는 것이 좋습니다. "
      "운동 세션(3회)이 적었다면, 가벼운 근력 운동이나 균형 감각을 기르는 활동을 추가해보세요. "
      "무리한 운동보다는 지속 가능한 운동 루틴을 설정하고, 주당 3~5회 적절한 운동을 유지하는 것이 중요합니다.";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "$username 님 맞춤 운동 추천"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              _buildBox("✅ 한달 간 운동 분석", monthlyExerciseAnalysis),
              SizedBox(height: 20),
              _buildBox("✅ 어제의 운동 분석", yesterdayExerciseAnalysis),
              SizedBox(height: 20),
              _buildBox("✅ 추천하는 운동 / 주의사항", exerciseTips),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade400, width: 1.5),
          ),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
