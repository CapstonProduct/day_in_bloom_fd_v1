import 'package:flutter/material.dart';

class CodeExplanationModal extends StatelessWidget {
  const CodeExplanationModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        "어르신 코드 등록",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "어르신 고유 코드란?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "어르신에게 직접 코드를 받으셔야 합니다!\n\n"
                  "보호자는 보호자 고유 코드 (형식: xxx112), "
                  "의사는 의사 고유 코드 (형식: ddd112)를 입력하시면 됩니다.\n\n"
                  "어르신의 고유 코드를 제공한 사용자는\n"
                  "어르신의 건강 정보를 열람하고, "
                  "건강 관련 조언 및 응원을 남길 수 있습니다.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "⚠ 주의사항",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "전문적 진단을 위해 필요한\n"
                  "로우데이터에의 접근은 '의사' 역할을 가진 사용자에게만 허용됩니다.\n\n"
                  "의사라면 반드시 의사 코드를 입력하세요!",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "확인",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
      ],
    );
  }
}
