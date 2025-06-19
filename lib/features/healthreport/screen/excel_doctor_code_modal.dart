import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelDoctorCodeModal {
  static void show(BuildContext context, String reportDate, String encodedId) {
    TextEditingController codeController = TextEditingController();

    String formatDate(String input) {
      return input.replaceAll(' ', '').replaceAll('/', '-');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '로우 데이터 엑셀 다운로드',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '의사 고유 코드를 입력해 주세요.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text(
                '취소',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredCode = codeController.text.trim();
                if (enteredCode.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('코드를 입력해 주세요.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                final formattedDate = formatDate(reportDate);

                final uri = Uri.parse(
                        'https://e1tbu7jvyh.execute-api.ap-northeast-2.amazonaws.com/Prod/reports/excel')
                    .replace(queryParameters: {
                  'doctor_code': enteredCode,
                  'encodedId': encodedId,
                  'report_date': formattedDate,
                });

                try {
                  final response = await Dio().getUri(uri);
                  if (response.statusCode == 200) {
                    final jsonResponse = response.data;
                    if (jsonResponse['doctor_valid'] == false) {
                      // context가 유효할 때 호출
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('유효하지 않은 의사 코드입니다.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } else if (jsonResponse['doctor_valid'] == true) {
                      final url = jsonResponse['presignedUrl'] as String;
                      final username = jsonResponse['username'] ?? 'unknown';

                      final filename = '로우데이터_${username}_$formattedDate.xlsx';

                      await _downloadFile(context, url, filename);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('서버 오류: ${response.statusCode}'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('오류가 발생했습니다: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _downloadFile(
      BuildContext context, String url, String filename) async {
    try {
      String filePath;

      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('저장소 접근 권한이 필요합니다.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        final downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('다운로드 폴더를 찾을 수 없습니다.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        filePath = '${downloadDir.path}/$filename';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        filePath = '${dir.path}/$filename';
      }

      final dio = Dio();
      final downloadResponse = await dio.download(
        url,
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );

      if (downloadResponse.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('파일 다운로드가 완료되었습니다:\n$filename')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('다운로드 실패: 상태코드 ${downloadResponse.statusCode}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 중 오류 발생: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
