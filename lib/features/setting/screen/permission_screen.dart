import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final Map<String, bool> permissions = {
    '리포트 생성 알림': true,
    '이상 징후 알림': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '알림 설정', showBackButton: true),
      body: ListView.builder(
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          String key = permissions.keys.elementAt(index);
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            color: index.isEven ? Colors.grey[200] : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  key,
                  style: const TextStyle(fontSize: 16),
                ),
                Switch(
                  value: permissions[key]!,
                  onChanged: (bool value) {
                    setState(() {
                      permissions[key] = value;
                      debugPrint(permissions.toString());  // 불린 값 업데이트 확인용
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
