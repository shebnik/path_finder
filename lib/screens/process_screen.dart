import 'package:flutter/material.dart';
import 'package:path_finder/api/api_client.dart';
import 'package:path_finder/models/path_task.dart';
import 'package:path_finder/models/task_result.dart';
import 'package:path_finder/screens/result_list_screen.dart';
import 'package:path_finder/services/path_finder.dart';

class ProcessScreen extends StatefulWidget {
  const new({required this.api, required this.url, super.key});

  final ApiClient api;

  final Uri url;

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

sealed class _ProcessState {
  const new();
}

final class _Loading extends _ProcessState {
  const new();
}

final class _LoadFailed extends _ProcessState {
  const new(this.message);
  final String message;
}

final class _Calculating extends _ProcessState {
  const new(this.solved, this.total);
  final int solved;
  final int total;
}

final class _Calculated extends _ProcessState {
  const new(this.results, {this.isSending = false, this.sendError});
  final List<TaskResult> results;
  final bool isSending;
  final String? sendError;
}

class _ProcessScreenState extends State<ProcessScreen> {
  static const _finder = PathFinder();

  _ProcessState _state = const _Loading();

  @override
  void initState() {
    super.initState();
    _loadAndSolve();
  }

  void _update(_ProcessState state) {
    if (mounted) setState(() => _state = state);
  }

  Future<void> _loadAndSolve() async {
    final List<PathTask> tasks;
    try {
      tasks = await widget.api.fetchTasks(widget.url);
    } on ApiException catch (e) {
      _update(_LoadFailed(e.message));
      return;
    }
    if (tasks.isEmpty) {
      _update(const _LoadFailed('The server returned no tasks to process.'));
      return;
    }

    final results = <TaskResult>[];
    for (final task in tasks) {
      final steps = _finder.findPath(task.grid, task.start, task.end);
      results.add(TaskResult(task: task, steps: steps));

      if (!mounted) return;
      _update(_Calculating(results.length, tasks.length));
    }
    _update(_Calculated(List.unmodifiable(results)));
  }

  void _retry() {
    _update(const _Loading());
    _loadAndSolve();
  }

  Future<void> _send(List<TaskResult> results) async {
    _update(_Calculated(results, isSending: true));
    try {
      await widget.api.submitResults(widget.url, results);
    } on ApiException catch (e) {
      _update(_Calculated(results, sendError: e.message));
      return;
    }
    if (!mounted) return;
    _update(_Calculated(results));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultListScreen(results: results),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = _buildBottom(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Process screen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: Center(child: _buildStatus(context))),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context) => switch (_state) {
    _Loading() => const _StatusView(message: 'Loading tasks…'),
    _LoadFailed(:final message) => Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
    _Calculating(:final solved, :final total) => _StatusView(
      message: 'Calculating shortest paths…',
      progress: solved / total,
    ),
    _Calculated() => const _StatusView(
      message:
          'All calculations has finished, you can send your results to server',
      progress: 1,
    ),
  };

  Widget? _buildBottom(BuildContext context) => switch (_state) {
    _LoadFailed() => ElevatedButton(
      onPressed: _retry,
      child: const Text('Try again'),
    ),
    _Calculated(:final results, :final isSending, :final sendError) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sendError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              sendError,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ElevatedButton(
          onPressed: isSending ? null : () => _send(results),
          child: isSending
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send results to server'),
        ),
      ],
    ),
    _Loading() || _Calculating() => null,
  };
}

class _StatusView extends StatelessWidget {
  const new({required this.message, this.progress});

  final String message;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (progress != null) ...[
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        ],
        SizedBox.square(
          dimension: 90,
          child: CircularProgressIndicator(value: progress),
        ),
      ],
    );
  }
}
