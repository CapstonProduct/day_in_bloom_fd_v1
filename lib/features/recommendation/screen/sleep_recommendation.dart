import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class SleepRecommendationScreen extends StatelessWidget {
  const SleepRecommendationScreen({super.key});

  final String username = "최예름";

  final String monthlySleepAnalysis = 
      "지난 한 달 동안 평균 총 수면 시간은 6.5시간이며, 깊은 수면 비율은 22.0%로 나타났습니다. "
      "REM 수면 비율은 28.0%, 얕은 수면 비율은 49.4%로, 균형 잡힌 수면 패턴을 유지하는 것이 중요합니다. "
      "평균 야간 각성 시간은 42.7분, 각성 횟수는 4.3회로 나타났으며, 이는 수면의 연속성과 질에 영향을 미칠 수 있습니다. "
      "수면 효율은 평균 83.7%로 비교적 양호하지만, 개선이 필요한 경우 수면 환경 조절이 필요합니다. "
      "하루 평균 활동량은 65.3분이며, 적절한 신체 활동이 수면의 질에 긍정적인 영향을 미칠 수 있습니다.";

  final String yesterdaySleepAnalysis = 
      "어제의 총 수면 시간은 6.0시간이었으며, 깊은 수면 비율은 14.8%였습니다. "
      "REM 수면은 24.6%, 얕은 수면은 66.2%로 나타났습니다. "
      "어제 야간 중 1회의 각성이 있었으며, 총 58분 동안 깨어 있었습니다. "
      "수면 효율은 79.8%로, 최근 평균과 비교해 떨어졌습니다. "
      "하루 활동량은 62분으로, 수면과의 상관관계를 고려해 지속적인 운동 습관을 유지하는 것이 좋습니다.";

  final String sleepTips = 
      "깊은 수면을 늘리기 위해 수면 전 명상이나 가벼운 스트레칭을 추천합니다. "
      "수면 중 자주 깨어난다면, 침실 온도 및 습도를 조절하고 빛과 소음이 없는 환경을 조성하는 것이 중요합니다. "
      "평균 수면 효율을 높이기 위해 일정한 수면 루틴을 유지하고, 자기 전 스마트폰 사용을 줄이는 것이 도움이 될 수 있습니다. "
      "어제의 활동량(62분)이 충분하지 않았다면, 낮 동안의 가벼운 운동을 추가하는 것이 수면 질을 향상시킬 수 있습니다. "
      "스트레스 지수가 높다면, 취침 전 이완 기술을 활용하여 긴장을 풀어주는 것이 효과적입니다.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "$username 님 수면 행동 추천"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              _buildBox("✅ 한달 간 수면 분석", monthlySleepAnalysis),
              SizedBox(height: 20),
              _buildBox("✅ 어제의 수면 분석", yesterdaySleepAnalysis),
              SizedBox(height: 20),
              _buildBox("✅ 양질의 수면을 위한 행동 / 주의사항", sleepTips),
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
