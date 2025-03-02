import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:day_in_bloom_fd_v1/widgets/app_bar.dart';

class ExvideoScreen extends StatefulWidget {
  const ExvideoScreen({super.key});

  @override
  State<ExvideoScreen> createState() => _ExvideoScreenState();
}

class _ExvideoScreenState extends State<ExvideoScreen> {
  static const List<Map<String, String>> videos = [
    {
      'title': '천태만상',
      'url': 'https://youtu.be/a3Vo5vodbRQ?feature=shared',
    },
    {
      'title': '국민체조',
      'url': 'https://youtu.be/a72NCO0OFXA?feature=shared',
    },
    {
      'title': '내 나이가 어때서',
      'url': 'https://youtu.be/-JWyAuNiEYI?feature=shared',
    },
  ];

  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = videos.map((video) {
      final videoId = YoutubePlayer.convertUrlToId(video['url']!)!;
      return YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '운동 영상 추천', showBackButton: true),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            child: Column(
              children: [
                Text(
                  video['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: YoutubePlayer(
                      controller: _controllers[index],
                      showVideoProgressIndicator: true,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _launchURL(video['url']!),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 80),
                  ),
                  child: const Text('유튜브로 시청하기', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
