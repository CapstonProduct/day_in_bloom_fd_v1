import 'package:day_in_bloom_fd_v1/features/healthreport/screen/excel_doctor_code_modal.dart';
import 'package:flutter/material.dart';

class ExcelDownloadModal {
  static Future<bool?> show(BuildContext context, String reportDate, String encodedId) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '로우 데이터\n엑셀 다운로드',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '로우 데이터 다운로드를\n진행하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                    ExcelDoctorCodeModal.show(context, reportDate, encodedId);
                  },
                  child: const Text('예', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); 
                  },
                  child: const Text('아니요', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
