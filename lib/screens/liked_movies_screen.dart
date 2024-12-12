import 'package:flutter/material.dart';
import '../utils/file_helper.dart';

class LikedMoviesScreen extends StatefulWidget {
  const LikedMoviesScreen({super.key});

  @override
  State<LikedMoviesScreen> createState() => _LikedMoviesScreenState();
}

class _LikedMoviesScreenState extends State<LikedMoviesScreen> {
  Set<Map<String, dynamic>> likedMovies = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedMovies();
  }

  Future<void> _loadLikedMovies() async {
    setState(() {
      isLoading = true;
    });

    final movies = await FileHelper.getLikedMovies();

    if (mounted) {
      setState(() {
        likedMovies = movies;
        isLoading = false;
      });
    }
  }

  Future<void> _removeMovie(int movieId) async {
    await FileHelper.removeLikedMovie(movieId);
    await _loadLikedMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Movies'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No liked movies yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Swipe right on movies you like',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: likedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = likedMovies.elementAt(index);
                    return Dismissible(
                      key: Key(movie['id'].toString()),
                      onDismissed: (direction) => _removeMovie(movie['id']),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: movie['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                                width: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset('assets/images/movie.png',
                                        width: 50),
                              )
                            : Image.asset('assets/images/movie.png', width: 50),
                        title: Text(movie['title']),
                        subtitle: Text(
                            'Release Date: ${movie['release_date'] ?? 'N/A'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeMovie(movie['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
