import 'dart:io';

import 'package:background_downloader/background_downloader.dart'
    show FileDownloader, TaskStatus;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/network/cached_image_provider.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_attachment.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/ui/confirmation_dialog.dart';

/// Zeigt die Anhänge einer Aufgabe (Bild-Thumbnails + Dateiliste) und
/// erlaubt Hochladen (Kamera/Fotomediathek/Dateien), Herunterladen und Löschen.
/// Wird sowohl in der Aufgaben-Ansicht (BottomSheet) als auch auf der
/// Bearbeiten-Seite verwendet und verwaltet seine Anhangsliste selbst.
class TaskAttachmentsSection extends ConsumerStatefulWidget {
  final Task task;
  final bool editable;

  /// Öffnet eine lokale Datei; injizierbar für Tests
  /// (Default: FileDownloader().openFile, ein Plattform-Kanal).
  final Future<void> Function(String path)? openLocalFile;

  const TaskAttachmentsSection({
    super.key,
    required this.task,
    this.editable = true,
    this.openLocalFile,
  });

  @override
  ConsumerState<TaskAttachmentsSection> createState() =>
      _TaskAttachmentsSectionState();
}

class _TaskAttachmentsSectionState
    extends ConsumerState<TaskAttachmentsSection> {
  late List<TaskAttachment> _attachments;
  Map<String, String>? _headers;

  /// Lokal vorliegende Anhang-Pfade (heruntergeladen oder vorgeladen), Schlüssel
  /// = Anhang-ID. Wird einmalig geladen, damit „Öffnen"/Vollbild ohne Netz geht.
  Map<int, String> _localPaths = {};

  /// Stabile ImageProvider-Instanzen (kein Neu-Laden bei jedem setState),
  /// Schlüssel = `<id>|<previewSize>`.
  final Map<String, ImageProvider> _providerCache = {};

  /// Download-Fortschritt pro Anhang (`null` = kein aktiver Download).
  final Map<int, ValueNotifier<double?>> _downloadProgress = {};

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.of(widget.task.attachments);
    ref.read(taskRepositoryProvider).attachmentHeaders().then((headers) {
      if (mounted) setState(() => _headers = headers);
    });
    // Lokale Pfade (Prefetch/Download) laden → lokale Datei zuerst nutzen.
    ref
        .read(offlineWriterProvider)
        .attachmentLocalPathsForTask(widget.task.id)
        .then((paths) {
          if (mounted && paths.isNotEmpty) {
            setState(() {
              _localPaths = paths;
              _providerCache.clear(); // ggf. gecachte Netz-Provider verwerfen
            });
          }
        });
  }

  @override
  void dispose() {
    for (final notifier in _downloadProgress.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  ValueNotifier<double?> _progressNotifier(int id) =>
      _downloadProgress.putIfAbsent(id, () => ValueNotifier<double?>(null));

  bool _isImage(TaskAttachment attachment) =>
      attachment.file.mime.startsWith('image/');

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = _attachments.where(_isImage).toList();
    final files = _attachments.where((a) => !_isImage(a)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).attachments,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (_uploading)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (widget.editable)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: AppLocalizations.of(context).addAttachment,
                onPressed: _uploading ? null : _showUploadOptions,
              ),
          ],
        ),
        if (images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) => _buildThumbnail(images[index]),
          ),
        ...files.map(_buildFileTile),
      ],
    );
  }

  /// Lokal vorliegender Pfad eines Anhangs (Offline-Platzhalter oder
  /// heruntergeladen/vorgeladen), sonst `null`.
  String? _localPathOf(TaskAttachment a) =>
      a.localFilePath ?? _localPaths[a.id];

  /// Lokale Datei zuerst (FileImage, ohne Netz); sonst der authentifizierte
  /// Platten-Cache. Provider werden memoisiert, damit setState (Upload,
  /// Fortschritt) sie nicht neu erzeugt. `previewSize` gilt nur für Server-Bilder.
  ImageProvider? _imageProvider(TaskAttachment attachment, {String? previewSize}) {
    final cacheKey = '${attachment.id}|${previewSize ?? ''}';
    final cached = _providerCache[cacheKey];
    if (cached != null) return cached;

    final localPath = _localPathOf(attachment);
    if (localPath != null) {
      final provider = FileImage(File(localPath));
      _providerCache[cacheKey] = provider;
      return provider;
    }
    if (_headers == null) return null; // warten bis Auth-Header geladen sind
    final url = ref
        .read(taskRepositoryProvider)
        .attachmentUrl(widget.task.id, attachment.id, previewSize: previewSize);
    final provider = AuthCachedImageProvider(
      url,
      headers: _headers!,
      cache: ref.read(imageDiskCacheProvider),
    );
    _providerCache[cacheKey] = provider;
    return provider;
  }

  Widget _buildThumbnail(TaskAttachment attachment) {
    final provider = _imageProvider(attachment, previewSize: 'md');

    return GestureDetector(
      onTap: () => _openImageViewer(attachment),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: provider == null
            ? Container(color: Theme.of(context).hoverColor)
            : Image(
                image: provider,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Theme.of(context).hoverColor,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                errorBuilder: (context, error, stack) => Container(
                  color: Theme.of(context).hoverColor,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }

  Widget _buildFileTile(TaskAttachment attachment) {
    final progress = _progressNotifier(attachment.id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(
        attachment.file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: ValueListenableBuilder<double?>(
        valueListenable: progress,
        builder: (context, value, _) {
          if (value == null) return Text(_formatSize(attachment.file.size));
          // Laufender Download: determinater Balken (indeterminate bei 0).
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(value: value == 0 ? null : value),
          );
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadAndOpen(attachment),
          ),
          if (widget.editable)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(attachment),
            ),
        ],
      ),
    );
  }

  void _openImageViewer(TaskAttachment attachment) {
    final provider = _imageProvider(attachment);
    if (provider == null) return; // Auth-Header noch nicht geladen
    // Bereits gecachtes md-Thumbnail als Sofort-Platzhalter hinter dem Original.
    final thumbnail = _imageProvider(attachment, previewSize: 'md');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AttachmentImageViewer(
          attachment: attachment,
          image: provider,
          thumbnail: thumbnail,
          progress: _progressNotifier(attachment.id),
          onDownload: () => _downloadAndOpen(attachment),
          onDelete: widget.editable
              ? () async {
                  final deleted = await _confirmDelete(attachment);
                  if (deleted && context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
        ),
      ),
    );
  }

  Future<void> _showUploadOptions() async {
    final localizations = AppLocalizations.of(context);
    final picker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(localizations.attachmentCamera),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final photo = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 90,
                );
                if (photo != null) await _upload([photo.path]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(localizations.attachmentGallery),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final photos = await picker.pickMultiImage(imageQuality: 90);
                if (photos.isNotEmpty) {
                  await _upload(photos.map((e) => e.path).toList());
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(localizations.attachmentFile),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                );
                final paths =
                    result?.files
                        .map((f) => f.path)
                        .whereType<String>()
                        .toList() ??
                    [];
                if (paths.isNotEmpty) await _upload(paths);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _upload(List<String> paths) async {
    setState(() => _uploading = true);
    final result = await ref
        .read(offlineWriterProvider)
        .uploadAttachments(
          widget.task.id,
          paths,
          uploadedBy: ref.read(currentUserProvider),
        );
    if (!mounted) return;

    setState(() {
      _uploading = false;
      switch (result) {
        case AttachmentUploaded(:final attachments):
          _attachments.addAll(attachments);
        case AttachmentQueued(:final placeholders):
          // Offline: Platzhalter (localFilePath) sofort als Thumbnail zeigen.
          _attachments.addAll(placeholders);
        case AttachmentFailed():
        case AttachmentDeleted():
          break;
      }
    });
    if (result is AttachmentFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).attachmentUploadFailed),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(TaskAttachment attachment) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showConfirmationDialog(
      context,
      title: localizations.attachmentDeleteTitle,
      message: localizations.attachmentDeleteMessage,
      confirmLabel: localizations.delete,
      cancelLabel: localizations.cancel,
      isDestructive: true,
    );
    if (!confirmed) return false;

    final result = await ref
        .read(offlineWriterProvider)
        .deleteAttachment(
          widget.task.id,
          attachment.id,
          localFilePath: attachment.localFilePath,
        );
    if (!mounted) return false;

    if (result is AttachmentDeleted) {
      setState(() => _attachments.removeWhere((a) => a.id == attachment.id));
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).attachmentUploadFailed),
      ),
    );
    return false;
  }

  Future<void> _downloadAndOpen(TaskAttachment attachment) async {
    final writer = ref.read(offlineWriterProvider);

    // Offline (oder bereits heruntergeladen/vorgeladen): lokale Datei öffnen.
    final localPath =
        _localPathOf(attachment) ??
        await writer.attachmentLocalFilePath(attachment.id);
    if (localPath != null && await File(localPath).exists()) {
      final open =
          widget.openLocalFile ??
          (path) => FileDownloader().openFile(filePath: path);
      await open(localPath);
      return;
    }

    // Download mit Fortschritt (background_downloader meldet 0..1, <0 = offen).
    final notifier = _progressNotifier(attachment.id);
    notifier.value = 0;
    final update = await ref
        .read(taskRepositoryProvider)
        .downloadAttachment(
          widget.task.id,
          attachment,
          onProgress: (p) => notifier.value = p < 0 ? null : p,
        );
    notifier.value = null;
    if (!mounted) return;

    if (update.status == TaskStatus.complete) {
      // Pfad merken, damit „Öffnen" später auch offline funktioniert.
      final path = await update.task.filePath();
      await writer.registerDownloadedFile(
        widget.task.id,
        TaskAttachmentDto.fromDomain(attachment),
        path,
      );
      _localPaths[attachment.id] = path;
      FileDownloader().openFile(task: update.task);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).attachmentDownloadFailed),
        ),
      );
    }
  }
}

class _AttachmentImageViewer extends StatelessWidget {
  final TaskAttachment attachment;
  final ImageProvider image;

  /// Bereits gecachtes Thumbnail als Sofort-Platzhalter (Hintergrund).
  final ImageProvider? thumbnail;

  /// Fortschritt eines „Öffnen"-Downloads (`null` = keiner aktiv).
  final ValueListenable<double?> progress;
  final VoidCallback onDownload;
  final Future<void> Function()? onDelete;

  const _AttachmentImageViewer({
    required this.attachment,
    required this.image,
    required this.progress,
    this.thumbnail,
    required this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(attachment.file.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: onDownload),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDelete!(),
            ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              maxScale: 6,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sofort sichtbarer, leicht abgedunkelter Thumbnail-Hintergrund.
                  if (thumbnail != null)
                    Opacity(
                      opacity: 0.4,
                      child: Image(image: thumbnail!, fit: BoxFit.contain),
                    ),
                  Image(
                    image: image,
                    // Original blendet über dem Thumbnail ein.
                    frameBuilder: (context, child, frame, wasSync) =>
                        AnimatedOpacity(
                          opacity: frame == null && !wasSync ? 0 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: child,
                        ),
                    loadingBuilder: (context, child, chunk) {
                      if (chunk == null) return child;
                      final total = chunk.expectedTotalBytes;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: total != null && total > 0
                              ? chunk.cumulativeBytesLoaded / total
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Download-Fortschritt („Öffnen") als Balken oben.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double?>(
              valueListenable: progress,
              builder: (context, value, _) => value == null
                  ? const SizedBox.shrink()
                  : LinearProgressIndicator(value: value == 0 ? null : value),
            ),
          ),
        ],
      ),
    );
  }
}
