import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  final String userName = '최예름';
  final String birthDate = '1900-00-00';
  final String gender = '여성';

  final String address = '서울특별시 광진구';
  final String phoneNumber = '010-1234-5678';
  final String heightWeight = '155 cm / 50 kg';

  final String breakfastTime = '09:00';
  final String lunchTime = '13:00';
  final String dinnerTime = '18:00';

  final String guardianCode = 'xxx112';
  final String doctorCode = 'ddd112';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 보기', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildMealAndCheckupRow(context),
            const SizedBox(height: 16),
            _buildCodeSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(birthDate),
            Text(gender),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            context.go('/homeSetting/viewProfile/modifyProfile');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
          ),
          child: const Text(
            '내 정보 수정', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return _buildInfoContainer('기본 정보', [
      _buildInfoItem('주소', address),
      _buildInfoItem('전화번호', phoneNumber),
      _buildInfoItem('신장 / 체중', heightWeight),
    ]);
  }

  Widget _buildMealAndCheckupRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoContainer('추가 정보', [
            _buildInfoItem('아침시간', breakfastTime),
            _buildInfoItem('점심시간', lunchTime),
            _buildInfoItem('저녁시간', dinnerTime),
          ]),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFcfe3d7),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: () {
            context.go('/homeSetting/viewProfile/medCheckup');
          },
          child: const Text('건강검진 내역\n원클릭으로\n가져오기', textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildCodeSection(BuildContext context) {
    return _buildInfoContainer(
      '고유 코드 보기',
      [
        _buildInfoItem('보호자 고유 코드', guardianCode),
        _buildInfoItem('의사 고유 코드', doctorCode),
      ],
      onHelpPressed: () {
        _showHelpDialog(context);
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '보호자 고유 코드란?',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [          
            Text(
              '• 보호자에게는 보호자 고유코드(형식: xxx112),\n'
              '• 의사에게는 의사 고유코드(형식: ddd112)를\n  제공하세요.',
            ),
            SizedBox(height: 10),
            Text(
              '어르신의 고유 코드를 받은 사용자는\n어르신의 건강 정보를 열람하고, 어르신께 '
              '건강 관련 조언 및 응원을 남길 수 있습니다!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '⚠ 주의사항  ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            Text(
              '보호자나 의사가 아닌 사람에게 고유 코드를\n제공하지 마세요!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
            ),
            child: const Text(
              '확인', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String title, List<Widget> children, {VoidCallback? onHelpPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (onHelpPressed != null)
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.grey),
                onPressed: onHelpPressed,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ListTile.divideTiles(
              context: null,
              color: Colors.grey,
              tiles: children,
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
