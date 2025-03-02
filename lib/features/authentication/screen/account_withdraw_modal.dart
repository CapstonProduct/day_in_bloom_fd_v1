import 'package:flutter/material.dart';

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
            // 회원 탈퇴 로직 추가 & 초기 로그인 화면으로 이동 추가
            Navigator.of(context).pop();
            // context.go('/homeSetting/logoutAndCancel');
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