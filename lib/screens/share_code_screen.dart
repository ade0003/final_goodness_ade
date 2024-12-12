import 'package:final_goodness_ade/screens/liked_movies_screen.dart';
import 'package:final_goodness_ade/screens/movie_selection_screen.dart';
import 'package:final_goodness_ade/utils/app_state.dart';
import 'package:final_goodness_ade/utils/http_helper.dart';
import 'package:final_goodness_ade/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  String code = "Unset";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  void _startSession() async {
    setState(() {
      isLoading = true;
    });

    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;

    if (kDebugMode) {
      print('Device ID from share code screen: $deviceId');
    }

    try {
      final response = await HttpHelper.startSession(deviceId);

      if (mounted) {
        setState(() {
          code = response["data"]["code"];
        });
        await Provider.of<AppState>(context, listen: false)
            .setSessionId(response["data"]["session_id"]);

        if (kDebugMode) {
          print('Started session with ID: ${response["data"]["session_id"]}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting session');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Night'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikedMoviesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Share this code with your movie friend',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.baseSpacing * 2),
            Container(
              padding: const EdgeInsets.all(AppTheme.baseSpacing * 2),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(AppTheme.baseSpacing),
              ),
              child: Text(
                code,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppTheme.baseSpacing * 2),
            SizedBox(
              width: 150,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: code != "Unset"
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MovieSelectionScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie, size: 50),
                      SizedBox(height: 8),
                      Text(
                        'Start\nMatching',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
