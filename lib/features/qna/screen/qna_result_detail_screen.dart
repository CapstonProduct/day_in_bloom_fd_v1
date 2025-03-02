import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QnaResultDetailScreen extends StatelessWidget {
  const QnaResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime selectedDate = GoRouterState.of(context).extra as DateTime? ?? DateTime.now();
    final String formattedDate = DateFormat('yyyy / MM / dd').format(selectedDate);

    return Scaffold(
      appBar: CustomAppBar(title: "$formattedDate 분석 결과"),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "AI 분석 결과",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 1.5,
                  ),
                ),
                child: SizedBox(
                  height: 500,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Text(
                        "긍정적 결과에 대한 분석:\n"
                        "- 식사 후 소화 상태가 아주 좋다고 하셨고, 어젯밤에는 푹 자서 개운하다고 하셨습니다. 이는 올바른 식사와 충분한 휴식을 취하셨다는 좋은 신호입니다.\n"
                        "- 오늘 근력 운동을 하시고, 사람들과 만나며 대화를 즐기는 등 산책/운동을 통해 즐거운 시간을 보내셨다고 하셨습니다. 활동적인 하루를 보내셨다는 점이 좋습니다.\n\n"
                        "- 또한, 오늘 하루 동안 기분이 매우 긍정적이었다고 응답하셨습니다. 이는 신체적 활동과 더불어 사회적 교류가 정신 건강에도 좋은 영향을 주었다는 뜻입니다.\n"
                        "- 식단 관리가 잘 이루어졌고, 특히 단백질과 신선한 채소를 충분히 섭취하셨습니다. 이러한 균형 잡힌 식사는 장기적으로 건강을 유지하는 데 중요한 역할을 합니다.\n\n"
                        "부정적 결과에 대한 분석:\n"
                        "- 수면 점수가 낮게 나왔고, 스트레스나 걱정이 있었다고 하셨습니다. 또한, 운동을 하면서 특별히 힘들었던 점이나 걱정되는 일이 있었다고도 하셨습니다. 이는 마음의 건강에 영향을 줄 수 있는 요소일 수 있습니다.\n"
                        "- 최근 며칠간 피로가 누적되어 있으며, 오후 시간대에 에너지가 급격히 떨어지는 경향을 보였습니다. 이는 휴식이 부족하거나 수면의 질이 낮기 때문일 가능성이 높습니다.\n\n"
                        "- 또한, 특정 음식이 속을 불편하게 했다고 응답하셨습니다. 이러한 반응이 반복된다면 음식 섭취 일지를 작성하여 어떤 음식이 영향을 미치는지 확인하는 것이 좋습니다.\n\n"
                        "해결 방안 및 동기 부여:\n"
                        "- 스트레스와 걱정을 해소하기 위해, 식사나 운동을 통해 건강을 유지하고 긍정적인 마음가짐을 유지하는 것이 중요합니다. 또한, 새로운 취미나 활동을 통해 즐거운 시간을 보내는 것도 좋은 방법입니다.\n"
                        "- 수면의 질을 개선하기 위해 자기 전 블루라이트 노출을 줄이고, 가벼운 스트레칭을 해보는 것이 추천됩니다.\n"
                        "- 식단 관리에서 특정 음식이 몸에 맞지 않는다면, 이를 조절하여 보다 건강한 식습관을 형성하는 것이 필요합니다.\n"
                        "- 기분이 저조한 날에는 짧은 산책이나 명상과 같은 간단한 활동을 추가하여 정신적 회복을 도모하는 것이 좋습니다.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
