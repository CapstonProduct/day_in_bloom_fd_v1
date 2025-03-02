import 'package:flutter/material.dart';

// Auth 화면 개발 후 -> onTap 이벤트 콜백 또는 필요한 파트에 아래 코드 넣어서 모달 사용
// AnomalyDetectionModal.show(context);

class AnomalyDetectionModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '수면 이상이\n감지되었습니다.',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '깊은 수면 시간이 적정 시간보다 부족합니다.\n이 문제에 대하여 대화를 진행하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // 대화 시작 로직 추가
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '예',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '아니요',
                    style: TextStyle(color: Colors.red),
                  ),
                ),               
              ],
            ),
          ],
        );
      },
    );
  }
}
