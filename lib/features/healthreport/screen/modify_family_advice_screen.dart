import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModifyFamilyAdviceScreen extends StatefulWidget {
  const ModifyFamilyAdviceScreen({super.key});

  @override
  _ModifyFamilyAdviceScreenState createState() => _ModifyFamilyAdviceScreenState();
}

class _ModifyFamilyAdviceScreenState extends State<ModifyFamilyAdviceScreen> {
  late TextEditingController _adviceController;
  final String defaultAdvice = "요즘 건강은 어떠세요? 날씨도 변덕스럽고 피곤하시진 않으신지 걱정돼요.\n"
      "밥은 잘 챙겨 드시고 계시죠? 바쁘시더라도 끼니 거르지 마시고, 몸에 좋은 음식도 꼭 챙겨 드세요!\n"
      "무리하지 마시고 가끔은 여유도 가지셨으면 좋겠어요.\n"
      "하루에 잠깐이라도 가벼운 운동하시고, 물도 자주 드세요.\n"
      "무엇보다 스트레스 받지 않고 편하게 지내셨으면 해요.\n"
      "부모님께서 건강하셔야 저도 마음이 놓이니까요. 항상 사랑하고, 오래오래 함께해요! 💕";

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
    final encodedId = GoRouterState.of(context).uri.queryParameters['encodedId'];

    return Scaffold(
      appBar: CustomAppBar(title: "조언 수정하기"),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("사랑하는 부모님께 드릴 조언을 수정하세요!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
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
                context.go('/homeElderlyList/calendar/report/familyAdvice?date=$selectedDate&name=$elderlyName&encodedId=$encodedId');
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
