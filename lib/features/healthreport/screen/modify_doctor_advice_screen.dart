import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModifyDoctorAdviceScreen extends StatefulWidget {
  const ModifyDoctorAdviceScreen({super.key});

  @override
  _ModifyDoctorAdviceScreenState createState() => _ModifyDoctorAdviceScreenState();
}

class _ModifyDoctorAdviceScreenState extends State<ModifyDoctorAdviceScreen> {
  late TextEditingController _adviceController;
  final String defaultAdvice = "어르신, 최근 건강 검진 결과를 바탕으로 몇 가지 조언을 드리겠습니다.\n"
                            "혈압 수치가 다소 변동이 있으시므로, 염분 섭취를 줄이고 규칙적인 운동을 권장드립니다.\n"
                            "특히, 가벼운 유산소 운동(예: 하루 30분 정도의 걷기)이 혈압 조절과 심혈관 건강에 도움이 됩니다.\n"
                            "또한, 공복 혈당 수치가 정상 범위보다 약간 높게 나타났으므로, 탄수화물 섭취를 조절하고 식사 후 가벼운 활동을 하시면 좋겠습니다.\n"
                            "체내 수분이 부족해지면 혈액 순환에 영향을 줄 수 있으니 하루 6~8잔 이상의 물을 섭취해 주세요.\n"
                            "무엇보다도, 피로감이나 어지럼증과 같은 증상이 지속된다면 즉시 진료를 받아보시길 권장합니다.\n"
                            "정기적인 건강 관리가 장기적인 건강 유지에 큰 도움이 되므로, 앞으로도 꾸준한 관리 부탁드립니다.";

  @override
  void initState() {
    super.initState();
    _adviceController = TextEditingController(text: defaultAdvice);
  }

  @override
  void dispose() {
    _adviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    final elderlyName = GoRouterState.of(context).uri.queryParameters['name'] ?? '어르신';

    return Scaffold(
      appBar: CustomAppBar(title: "조언 수정하기"),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("환자분의 소중한 건강을 위해 조언을 수정하세요!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 10),
            Text("$elderlyName 어르신", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            Text("[ $selectedDate ]", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),            
            SizedBox(height: 15),
            TextField(
              controller: _adviceController,
              maxLines: 15,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.5),
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                context.go('/homeElderlyList/calendar/report/doctorAdvice?date=$selectedDate&name=$elderlyName');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
              ),
              child: const Text(
                '수정 완료', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
