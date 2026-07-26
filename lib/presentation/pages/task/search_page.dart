import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/smart_list_providers.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/error_widget.dart';
import 'package:vikunja_app/presentation/pages/loading_widget.dart';
import 'package:vikunja_app/presentation/pages/task/task_edit_page.dart';
import 'package:vikunja_app/presentation/widgets/task/task_list_item.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_text_field.dart';
import 'package:vikunja_app/presentation/widgets/ui/empty_state.dart';

/// Globale, lokale Suche (offline) über alle Aufgaben im Stil von Microsoft
/// To Do: Suchfeld oben (autofocus), Treffer reaktiv als Aufgabenliste
/// darunter. Leere Eingabe zeigt keine Treffer; erst ein (debounced) Query
/// löst die Suche über [taskSearchProvider] aus.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AppTextField(
            controller: _controller,
            hint: l10n.searchHint,
            autofocus: true,
            prefixIcon: Icons.search,
            onChanged: _onChanged,
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? const SizedBox.shrink()
          : _SearchResults(query: _query),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(taskSearchProvider(query));

    return results.when(
      data: (tasks) => tasks.isEmpty
          ? EmptyState(icon: Icons.search_off, title: l10n.searchNoResults)
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskListItem(
                  key: Key(task.id.toString()),
                  task: task,
                  onTap: () => _onEdit(context, task),
                  onEdit: () => _onEdit(context, task),
                  onFavoriteToggle: () {
                    // Optimistisch; bei Server-Ablehnung rollt der
                    // OfflineWriter die Zeile zurück.
                    ref
                        .read(taskPageControllerProvider.notifier)
                        .updateTask(task..isFavorite = !task.isFavorite);
                  },
                  onCheckedChanged: (value) {
                    ref
                        .read(taskPageControllerProvider.notifier)
                        .updateTask(task..done = value);
                  },
                );
              },
            ),
      error: (err, _) => VikunjaErrorWidget(
        error: err,
        onRetry: () => ref.invalidate(taskSearchProvider(query)),
      ),
      loading: () => const LoadingWidget(),
    );
  }

  void _onEdit(BuildContext context, Task task) {
    Navigator.push<Task?>(
      context,
      MaterialPageRoute(builder: (_) => TaskEditPage(task: task)),
    );
  }
}
