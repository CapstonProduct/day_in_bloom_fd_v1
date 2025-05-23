import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfDownloadModal {
  static Future<bool?> show(BuildContext context, String reportDate, String encodedId) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '건강 리포트\nPDF 다운로드',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '건강 리포트 다운로드를\n진행하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(true); // true 반환
                    await _downloadPdf(context, reportDate, encodedId);
                  },
                  child: const Text('예', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); // false 반환
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

  static Future<void> _downloadPdf(BuildContext context, String rawDate, String encodedId) async {
    try {
      if (encodedId.isEmpty) throw Exception('사용자 정보 없음');

      final formattedDate = _formatDate(rawDate);
      final requestBody = {
        'encodedId': encodedId,
        'report_date': formattedDate,
      };

      final response = await http.post(
        Uri.parse('https://gz96dflvf2.execute-api.ap-northeast-2.amazonaws.com/default/get-pdf-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('PDF 링크 요청 실패');
      }

      final presignedUrl = jsonDecode(response.body)['presignedUrl'];
      if (presignedUrl == null) throw Exception('presignedUrl이 없습니다.');

      String filePath;

      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          throw Exception('저장소 접근 권한이 필요합니다.');
        }

        final downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          throw Exception('다운로드 폴더를 찾을 수 없습니다.');
        }

        filePath = '${downloadDir.path}/건강리포트_$formattedDate.pdf';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        filePath = '${dir.path}/건강리포트_$formattedDate.pdf';
      }

      final dio = Dio();
      final downloadResponse = await dio.download(
        presignedUrl,
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );

      if (downloadResponse.statusCode != 200) {
        throw Exception('다운로드 실패');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리포트가 저장되었습니다:\n건강리포트_$formattedDate.pdf')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다운로드 실패: 인터넷 연결 또는 리포트가 없습니다.')),
      );
    }
  }

  static String _formatDate(String input) {
    try {
      final cleaned = input.trim().replaceAll(RegExp(r'\s*/\s*'), '-');
      final parsed = DateTime.parse(cleaned);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return input;
    }
  }
}
