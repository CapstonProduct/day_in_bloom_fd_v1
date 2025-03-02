import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 추후 OAuth 로직 추가 예정
            context.go('/homeCalendar');
          },
          child: Text("OAuth 로그인"),
        ),
      ),
    );
  }
}
