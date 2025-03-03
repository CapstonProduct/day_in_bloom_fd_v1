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
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 보기', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return const CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
    );
  }

  Widget _buildInfoSection() {
    return _buildInfoContainer('기본 정보', [
      _buildInfoItem('이름', userName),
      _buildInfoItem('생년월일', birthDate),
      _buildInfoItem('성별', gender),
      _buildInfoItem('주소', address),
      _buildInfoItem('전화번호', phoneNumber),
    ]);
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
