import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Bottom-Sheet mit dem detaillierten Sync-Status: ausstehende und
/// fehlgeschlagene Outbox-Operationen samt Aktionen (jetzt synchronisieren,
/// fehlgeschlagene Op verwerfen). Wird per Tap auf den [SyncStatusBanner]
/// geöffnet.
class SyncStatusSheet extends ConsumerWidget {
  const SyncStatusSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const SyncStatusSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final opsAsync = ref.watch(pendingOpsListProvider);

    final ops = opsAsync.valueOrNull ?? const <PendingOp>[];
    final pending = ops.where((o) => o.lastError == null).toList();
    final failed = ops.where((o) => o.lastError != null).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          0,
          AppDimensions.md,
          AppDimensions.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(loc.syncSheetTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppDimensions.sm),
            Flexible(
              child: ops.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.lg,
                      ),
                      child: Text(
                        loc.syncSheetEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        if (pending.isNotEmpty) ...[
                          _sectionHeader(theme, loc.syncSheetPendingSection),
                          ...pending.map((op) => _OpTile(op: op)),
                        ],
                        if (failed.isNotEmpty) ...[
                          _sectionHeader(theme, loc.syncSheetFailedSection),
                          ...failed.map(
                            (op) => _OpTile(
                              op: op,
                              onDiscard: () => ref
                                  .read(offlineWriterProvider)
                                  .discardOp(op),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: AppDimensions.sm),
            FilledButton.icon(
              onPressed: () {
                ref.read(syncServiceProvider).syncNow();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.sync),
              label: Text(loc.syncSheetSyncNow),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(
      top: AppDimensions.sm,
      bottom: AppDimensions.xs,
    ),
    child: Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
      ),
    ),
  );
}

class _OpTile extends StatelessWidget {
  const _OpTile({required this.op, this.onDiscard});

  final PendingOp op;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = _opTitle(loc, op);
    final detail = op.lastError ?? _relativeTime(loc, op.createdAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(_opIcon(op.type)),
      title: Text(title),
      subtitle: Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: onDiscard == null
          ? null
          : TextButton(
              onPressed: () => onDiscard!(),
              child: Text(loc.syncSheetDiscard),
            ),
    );
  }

  IconData _opIcon(PendingOpType type) {
    switch (type.entityType) {
      case 'task':
        return Icons.check_box_outlined;
      case 'comment':
        return Icons.comment_outlined;
      case 'project':
        return Icons.folder_outlined;
      case 'bucket':
        return Icons.view_column_outlined;
      case 'label':
        return Icons.label_outline;
      case 'user':
        return Icons.settings_outlined;
      default:
        return Icons.sync_outlined;
    }
  }

  /// Menschenlesbarer Titel: Typ-Label + (falls vorhanden) Titel aus dem
  /// Payload (Task-/Projekt-/Bucket-Titel bzw. Kommentartext).
  String _opTitle(AppLocalizations loc, PendingOp op) {
    final label = _opLabel(loc, op.type);
    final subject =
        (op.payload['title'] ?? op.payload['comment']) as String?;
    if (subject == null || subject.isEmpty) return label;
    return '$label · $subject';
  }

  String _opLabel(AppLocalizations loc, PendingOpType type) {
    switch (type) {
      case PendingOpType.taskCreate:
        return loc.syncOpTaskCreate;
      case PendingOpType.taskUpdate:
        return loc.syncOpTaskUpdate;
      case PendingOpType.taskDelete:
        return loc.syncOpTaskDelete;
      case PendingOpType.taskMoveBucket:
      case PendingOpType.taskPosition:
        return loc.syncOpTaskMove;
      case PendingOpType.taskSetAssignees:
        return loc.syncOpAssignees;
      case PendingOpType.taskLabelBulk:
      case PendingOpType.labelCreate:
        return loc.syncOpLabel;
      case PendingOpType.commentCreate:
      case PendingOpType.commentUpdate:
      case PendingOpType.commentDelete:
        return loc.syncOpComment;
      case PendingOpType.projectCreate:
      case PendingOpType.projectUpdate:
      case PendingOpType.projectViewUpdate:
        return loc.syncOpProject;
      case PendingOpType.bucketCreate:
      case PendingOpType.bucketUpdate:
      case PendingOpType.bucketDelete:
        return loc.syncOpBucket;
      case PendingOpType.userSettings:
        return loc.syncOpSettings;
      case PendingOpType.attachmentUpload:
      case PendingOpType.attachmentDelete:
        return loc.syncOpGeneric;
    }
  }

  String _relativeTime(AppLocalizations loc, String createdAtIso) {
    final createdAt = DateTime.tryParse(createdAtIso);
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return loc.syncTimeJustNow;
    if (diff.inHours < 1) return loc.syncTimeMinutes(diff.inMinutes);
    if (diff.inDays < 1) return loc.syncTimeHours(diff.inHours);
    return loc.syncTimeDays(diff.inDays);
  }
}
