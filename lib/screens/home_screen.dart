import 'package:flutter/material.dart';
import 'package:path_finder/api/api_client.dart';
import 'package:path_finder/screens/process_screen.dart';
import 'package:path_finder/services/url_storage.dart';

class HomeScreen extends StatefulWidget {
  const new({required this.api, super.key});

  final ApiClient api;

  static Uri? parseApiUrl(String input) {
    final url = Uri.tryParse(input.trim());
    if (url == null || url.host.isEmpty) return null;
    if (!url.isScheme('http') && !url.isScheme('https')) return null;
    return url;
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _storage = UrlStorage();
  String? _error;

  @override
  void initState() {
    super.initState();
    _storage.load().then((saved) {
      if (saved != null && mounted) _controller.text = saved;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final url = HomeScreen.parseApiUrl(_controller.text);
    if (url == null) {
      setState(
        () => _error = 'Enter a valid URL starting with http:// or https://',
      );
      return;
    }
    setState(() => _error = null);
    await _storage.save(url.toString());
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProcessScreen(api: widget.api, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home screen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set valid API base URL in order to continue'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.compare_arrows),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(errorText: _error),
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: (_) => _start(),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _start,
                child: const Text('Start counting process'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
