import 'package:flutter/material.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class ReportFamilyAdviceScreen extends StatelessWidget {
  const ReportFamilyAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    
    return Scaffold(
      appBar: const CustomAppBar(title: "건강 리포트"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            const Text(
              "보호자님 조언",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41af7a),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text(
                        "조언과 응원",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 350,
                    child: Container(
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "요즘 건강은 어떠세요? 날씨도 변덕스럽고 피곤하시진 않으신지 걱정돼요.\n"
                            "밥은 잘 챙겨 드시고 계시죠? 바쁘시더라도 끼니 거르지 마시고, 몸에 좋은 음식도 꼭 챙겨 드세요!\n"
                            "무리하지 마시고 가끔은 여유도 가지셨으면 좋겠어요.\n"
                            "하루에 잠깐이라도 가벼운 운동하시고, 물도 자주 드세요.\n"
                            "무엇보다 스트레스 받지 않고 편하게 지내셨으면 해요.\n"
                            "부모님께서 건강하셔야 저도 마음이 놓이니까요. 항상 사랑하고, 오래오래 함께해요! 💕",                          
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
