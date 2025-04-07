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
    "1. 카카오 로그인 버튼을 누른 후\n카카오 계정으로 로그인하세요.",
    "2. 이전에 등록한 카카오 아이디로\n간편하게 로그인 할 수 있어요.",
    "3. 다른 카카오계정으로 로그인을\n선택하고 새로운 계정 로그인도 가능합니다.",
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 440,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: guideTexts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  guideTexts[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 15),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/login_guide_img/guide${index + 1}.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center( 
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: guideTexts.length,
                      effect: const WormEffect(
                        activeDotColor: Colors.amber,
                        dotHeight: 6,
                        dotWidth: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      const Text(
                        "자동 로그인은 네모를 클릭해주세요.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: _loginWithKakao,
                      child: const Text(
                        "카카오 로그인",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
