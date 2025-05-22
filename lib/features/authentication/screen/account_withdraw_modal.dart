import 'dart:convert';
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AccountWithdrawModal extends StatelessWidget {
  const AccountWithdrawModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AccountWithdrawModal();
      },
    );
  }

  Future<void> _handleWithdraw(BuildContext context) async {
    final kakaoUserId = await KakaoAuthService.getUserId();

    if (kakaoUserId == null) {
      debugPrint('사용자 ID를 가져올 수 없습니다.');
      return;
    }

    final url = dotenv.env['ACCOUNT_WITHDRAW_MODAL_API_URL'];
    if (url == null || url.isEmpty) {
      debugPrint('.env에 ACCOUNT_WITHDRAW_MODAL_API_URL이 설정되지 않았습니다.');
      return;
    }

    final body = {"kakao_user_id": kakaoUserId};
    debugPrint("탈퇴 요청 데이터:\n${const JsonEncoder.withIndent('  ').convert(body)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint("탈퇴 응답 상태: ${response.statusCode}");
      debugPrint("탈퇴 응답 본문: $responseBody");

      if (response.statusCode == 200) {
        await KakaoAuthService.logout();
        if (context.mounted) {
          context.go('/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("탈퇴 요청 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: const Text(
        '탈퇴 시 주의사항',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '회원 탈퇴를 진행하시면\n다음 사항이 적용됩니다:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 12),
          Text(
            '• 계정 및 모든 개인 정보가 영구적으로 삭제됩니다.\n'
            '• 저장된 데이터(건강 기록, 대화 내역 등)는 복구할 수 없습니다.\n'
            '• 가입된 서비스 및 혜택을 다시 이용하려면 새로운 계정이 필요합니다.\n',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            '정말 탈퇴하시겠습니까? 😢', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red), 
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '※ 탈퇴 후에도 관련 법령에 따라 일정 기간 보관되는 정보가 있을 수 있습니다.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _handleWithdraw(context);
          },
          child: const Text('예', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('돌아가기', style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }
}
