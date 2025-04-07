import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  final storage = FlutterSecureStorage();
  final List<String> guideTexts = [
    "1. 카카오 로그인 버튼을 누른 후\n카카오 계정 아이디로 로그인하세요.",
    "2. 카카오 계정의 비밀번호를 입력하세요.",
    "3. 카카오 서비스 약관을 확인하고,\n필요한 부분에 동의하세요.",
    "4. 카카오 추가 서비스 약관과\n개인정보에 관한 사항을 확인하세요."
  ];

  bool _autoLogin = false;

  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final user = await UserApi.instance.me();
      await storage.write(key: 'accessToken', value: token.accessToken);
      await storage.write(key: 'refreshToken', value: token.refreshToken);
      await storage.write(key: 'userId', value: user.id.toString());
      await storage.write(key: 'nickname', value: user.kakaoAccount?.profile?.nickname ?? 'unknown');
      await storage.write(key: 'autoLogin', value: _autoLogin.toString());

      if (context.mounted) context.go('/homeElderlyList');
    } catch (e) {
      print('로그인 실패: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("로그인 실패: $e")),
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final autoLogin = await storage.read(key: 'autoLogin');
    if (autoLogin == 'true') {
      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null) {
        context.go('/homeElderlyList');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 15),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  children: [
                    TextSpan(text: "카카오 로그인 가이드", style: TextStyle(color: Colors.amber)),
                    TextSpan(text: "를 확인하고\n로그인해 보세요!"),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: guideTexts.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(guideTexts[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Image.asset('assets/login_guide_img/guide${index + 1}.png',
                            fit: BoxFit.contain, width: MediaQuery.of(context).size.width * 0.8),
                      ],
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: guideTexts.length,
                effect: const WormEffect(activeDotColor: Colors.amber, dotHeight: 6, dotWidth: 6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _autoLogin,
                    onChanged: (value) {
                      setState(() {
                        _autoLogin = value!;
                      });
                    },
                    activeColor: Colors.amber,
                  ),
                  const Text("자동 로그인은 네모를 클릭해주세요.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: _loginWithKakao,
                  child: const Text("카카오 로그인",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
