import 'package:final_goodness_ade/screens/liked_movies_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/file_helper.dart';
import '../utils/app_state.dart';
import '../utils/http_helper.dart';
import '../screens/welcome_screen.dart';

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  State<MovieSelectionScreen> createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  List<Map<String, dynamic>> movies = [];
  int currentIndex = 0;
  int currentPage = 1;
  bool isLoading = false;
  bool isVoting = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final moviesResponse = await HttpHelper.fetchMovies(currentPage);
      if (kDebugMode) {
        print('Movies Response: $moviesResponse');
      }

      if (moviesResponse.containsKey('results')) {
        final results = moviesResponse['results'];
        if (results is List<dynamic>) {
          final movieList = results.cast<Map<String, dynamic>>();
          if (mounted) {
            setState(() {
              movies.addAll(movieList);
              currentPage++;
              isLoading = false;
            });
          }
        } else {
          if (kDebugMode) {
            print('Error: "results" is not a List<dynamic>');
          }
        }
      } else {
        if (kDebugMode) {
          print('Error: "results" key not found in the response');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading movies: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  void _showMatchDialog(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('We have a winner!', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You both chose: ${movie['title']}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (movie['poster_path'] != null)
                Image.network(
                  'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/movie.png', height: 200);
                  },
                )
              else
                Image.asset('assets/images/movie.png', height: 200),
              const SizedBox(height: 16),
              Text('Release Date: ${movie['release_date'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              Text(
                'Overview: ${movie['overview'] ?? 'No description available'}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _voteMovie(bool vote) async {
    if (isVoting) return;

    setState(() {
      isVoting = true;
    });

    try {
      String? sessionId =
          Provider.of<AppState>(context, listen: false).sessionId;
      int movieId = movies[currentIndex]['id'];

      if (kDebugMode) {
        print('Voting: movieId=$movieId, vote=$vote');
        print('Session ID when voting: $sessionId');
      }

      if (vote) {
        if (kDebugMode) {
          print('Saving movie to liked: ${movies[currentIndex]}');
        }
        await FileHelper.addLikedMovie(movies[currentIndex]);
      }

      final response = await HttpHelper.voteMovie(sessionId, movieId, vote);

      if (kDebugMode) {
        print('Vote Response: $response');
        print('Match status: ${response['data']['match']}');
      }

      if (mounted) {
        if (response['data']['match'] == true) {
          _showMatchDialog(movies[currentIndex]);
        } else {
          _moveToNextMovie();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _voteMovie: $e');
      }
      if (mounted) {
        _showErrorDialog('Error voting on movie');
      }
    } finally {
      if (mounted) {
        setState(() {
          isVoting = false;
        });
      }
    }
  }

  void _moveToNextMovie() {
    setState(() {
      currentIndex++;

      if (currentIndex >= movies.length) {
        currentIndex = movies.length - 1;
      }

      if (currentIndex >= movies.length - 5 && !isLoading) {
        _loadMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty || currentIndex >= movies.length) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentMovie = movies[currentIndex];

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
      body: Stack(
        children: [
          if (!isVoting)
            Dismissible(
              key: Key(currentMovie['id'].toString()),
              onDismissed: (direction) {
                _voteMovie(
                    direction == DismissDirection.endToStart ? false : true);
              },
              movementDuration: const Duration(milliseconds: 200),
              resizeDuration: const Duration(milliseconds: 500),
              background: Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                child: const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.thumb_up, color: Colors.white, size: 48),
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red.withOpacity(0.8),
                child: const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child:
                        Icon(Icons.thumb_down, color: Colors.white, size: 48),
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentMovie['title'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    currentMovie['poster_path'] != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w500${currentMovie['poster_path']}',
                            height: 300,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/images/movie.png',
                                  height: 300);
                            },
                          )
                        : Image.asset(
                            'assets/images/movie.png',
                            height: 300,
                          ),
                    const SizedBox(height: 20),
                    Text(
                        'Release Date: ${currentMovie['release_date'] ?? 'N/A'}'),
                    Text('Rating: ${currentMovie['vote_average'] ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
          if (isVoting)
            Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Center(
                child: Card(
                    elevation: 4,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Voting...",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ))),
              ),
            ),
        ],
      ),
    );
  }
}
