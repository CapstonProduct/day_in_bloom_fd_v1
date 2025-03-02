import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeQnaScreen extends StatelessWidget {
  const HomeQnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "건강 문답"),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/homeQna/healthQna');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFdbf2e6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                elevation: 3,
              ),
              child: Row(
                children: [
                  Image.asset('assets/qna_icon/health_qna.png', width: 150, height: 150),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "오늘의\n건강 문답\n진행하기",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "[ 주의사항 ]\n"
                          "오늘 이미 답변하시고\n다시 진행하신다면\n결과가 덮어쓰여집니다!",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.go('/homeQna/healthList');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfff6d4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                elevation: 3,
              ),
              child: Row(
                children: [
                  Image.asset('assets/qna_icon/qna_report.png', width: 140, height: 140),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      "지난\n건강 문답\n분석 결과\n확인",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
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
