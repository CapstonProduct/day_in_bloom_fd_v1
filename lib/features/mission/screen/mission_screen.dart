import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '오늘 할 일'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingOption(
                context,
                title: '오늘의 문답 완료',
                imagePath: 'assets/mission_icon/doctor.png',
                onTap: () {
                  context.go('/homeSetting/detail');
                },
              ),
              _buildSettingOption(
                context,
                title: '어제의 건강 리포트 확인하기',
                imagePath: 'assets/mission_icon/report.png',
                onTap: () {
                  context.go('/homeSetting/detail');
                },
              ),
              _buildSettingOption(
                context,
                title: '맞춤형 운동 추천 확인',
                imagePath: 'assets/mission_icon/runner.png',
                onTap: () {
                  context.go('/homeSetting/detail');
                },
              ),
              _buildSettingOption(
                context,
                title: '수면패턴에 따른 행동 추천 확인',
                imagePath: 'assets/mission_icon/recommendation.png',
                onTap: () {
                  context.go('/homeSetting/detail');
                },
              ),
              _buildSettingOption(
                context,
                title: '데일리 운동 영상 5분 따라하기',
                imagePath: 'assets/mission_icon/elderly.png',
                onTap: () {
                  context.go('/homeSetting/detail');
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌿 캘린더 마커의 의미',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '미션 1개 달성 → 씨앗\n미션 2개 달성 → 싹이 나온 씨앗\n미션 3개 달성 → 새싹\n미션 4개 달성 → 나뭇잎\n미션 5개 달성 → 꽃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    bool isChecked = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFf6f9f7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF41af7a),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Image.asset(
                          imagePath,
                          width: 45,
                          height: 45,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    activeColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
