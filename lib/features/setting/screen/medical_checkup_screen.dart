import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class MedicalCheckupScreen extends StatelessWidget {
  const MedicalCheckupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> checkupItems = [
      {'label': '이름', 'value': '최예름'},
      {'label': '생년월일', 'value': '1900-00-00'},
      {'label': '질환력 해당 여부', 'value': '협심증'},
      {'label': '흡연 여부', 'value': '비흡연자'},
      {'label': '질환', 'value': '당뇨병'},
      {'label': '신장', 'value': '155 cm'},
      {'label': '체중', 'value': '50 kg'},
      {'label': '허리둘레', 'value': '80 cm'},
      {'label': '체질량 지수', 'value': '25 kg/m²'},
      {'label': '시력 (좌/우)', 'value': '-1.0 / -1.0'},
      {'label': '청력 (좌/우)', 'value': '15 dB / 15 dB'},
      {'label': '혈압 (최고/최저)', 'value': '102 / 79 mmHg'},
      {'label': '요단백', 'value': '음성'},
    ];

    return Scaffold(
      appBar: CustomAppBar(title: '건강검진 내역', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: checkupItems.length,
          itemBuilder: (context, index) {
            return Container(
              color: index.isOdd ? Colors.white : Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '• ${checkupItems[index]['label']!}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  Text(
                    checkupItems[index]['value']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
