import 'package:flutter/material.dart';

class PdfDownloadModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '건강 리포트 PDF 다운로드',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '건강 리포트 다운로드를 진행하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // PDF 다운로드 로직 추가
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
