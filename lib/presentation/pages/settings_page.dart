import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/locale_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/notification_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/theming/theme_mode.dart';
import 'package:vikunja_app/core/utils/language_autonyms.dart';
import 'package:vikunja_app/core/utils/user_extensions.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/entities/version.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vikunja_app/core/di/data_source_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/presentation/widgets/ui/preset_sheet.dart';
import 'package:vikunja_app/presentation/widgets/user_avatar.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/presentation/manager/todo_prefs.dart';
import 'package:vikunja_app/presentation/widgets/task/smart_list_section.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';
import 'package:vikunja_app/presentation/widgets/ui/constrained_page.dart';
import 'package:vikunja_app/presentation/manager/settings_controller.dart';
import 'package:vikunja_app/presentation/pages/error_widget.dart';
import 'package:vikunja_app/presentation/pages/loading_widget.dart';
import 'package:vikunja_app/presentation/pages/login/login_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController durationTextController = TextEditingController();

  Version? newestVersion;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);

    final l10n = AppLocalizations.of(context);
    final overrideLocale = ref.watch(localeOverrideProvider).asData?.value;
    final resolvedLocale = Localizations.localeOf(context);
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final bool isSystemSelected = overrideLocale == null;
    final bool isFallback =
        isSystemSelected &&
        platformLocale.languageCode != resolvedLocale.languageCode;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        title: Text(
          l10n.settings,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ConstrainedPage(
        child: settings.when(
          data: (settings) {
            durationTextController.text = settings.refreshInterval.toString();

            return ListView(
              children: [
                _buildUserHeader(
                  ref,
                  settings.user,
                  settings.projects,
                  context,
                ),
                Divider(),
                ListTile(
                  title: Text(l10n.theme),
                  trailing: DropdownButton<FlutterThemeMode>(
                    items: [
                      DropdownMenuItem(
                        value: FlutterThemeMode.system,
                        child: Text(l10n.system),
                      ),
                      DropdownMenuItem(
                        value: FlutterThemeMode.light,
                        child: Text(l10n.light),
                      ),
                      DropdownMenuItem(
                        value: FlutterThemeMode.dark,
                        child: Text(l10n.dark),
                      ),
                    ],
                    value: settings.themeMode,
                    onChanged: (FlutterThemeMode? value) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setThemeMode(value ?? FlutterThemeMode.system);
                    },
                  ),
                ),
                ListTile(
                  title: Text(l10n.language),
                  subtitle: isFallback
                      ? Text(
                          'System language (${platformLocale.languageCode}${platformLocale.countryCode != null ? '-${platformLocale.countryCode}' : ''}) not supported. Using ${languageAutonym(resolvedLocale)}.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        )
                      : null,
                  trailing: DropdownButton<Locale?>(
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.systemLanguage),
                      ),
                      ...AppLocalizations.supportedLocales.map(
                        (loc) => DropdownMenuItem(
                          value: loc,
                          child: Text(languageAutonym(loc)),
                        ),
                      ),
                    ],
                    value: overrideLocale,
                    onChanged: (Locale? value) {
                      ref
                          .read(localeOverrideProvider.notifier)
                          .setLocale(value);
                    },
                  ),
                ),
                SwitchListTile(
                  title: Text(l10n.dynamicColors),
                  value: settings.dynamicColors,
                  onChanged: (bool? value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setDynamicColors(value ?? false);
                  },
                ),
                // To-Do-Verhaltensoptionen (lokal, KeyValue-Store).
                SwitchListTile(
                  title: Text(l10n.completionSoundSetting),
                  value:
                      ref.watch(completionSoundEnabledProvider).value ?? true,
                  onChanged: (value) => setCompletionSoundEnabled(
                    ref.read(keyValueDaoProvider),
                    value,
                  ),
                ),
                SwitchListTile(
                  title: Text(l10n.dateDetectionSetting),
                  value: ref.watch(dateDetectionEnabledProvider).value ?? true,
                  onChanged: (value) => setDateDetectionEnabled(
                    ref.read(keyValueDaoProvider),
                    value,
                  ),
                ),
                Divider(),
                // Smart-Lists einzeln ein-/ausblenden (wie in To Do).
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    l10n.smartListsSection,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                for (final list in SmartList.values)
                  SwitchListTile(
                    title: Text(smartListLook(context, list).title),
                    secondary: Icon(
                      smartListLook(context, list).icon,
                      color: smartListLook(context, list).color,
                    ),
                    value:
                        ref.watch(smartListEnabledProvider(list.name)).value ??
                        true,
                    onChanged: (value) => setSmartListEnabled(
                      ref.read(keyValueDaoProvider),
                      list.name,
                      value,
                    ),
                  ),
                SwitchListTile(
                  title: Text(l10n.hideEmptySmartLists),
                  value: ref.watch(hideEmptySmartListsProvider).value ?? false,
                  onChanged: (value) => setHideEmptySmartLists(
                    ref.read(keyValueDaoProvider),
                    value,
                  ),
                ),
                Divider(),
                SwitchListTile(
                  title: Text(l10n.dateStripSetting),
                  value: ref.watch(dateStripEnabledProvider).value ?? true,
                  onChanged: (value) =>
                      setDateStripEnabled(ref.read(keyValueDaoProvider), value),
                ),
                Divider(),
                CheckboxListTile(
                  title: Text(l10n.ignoreCertificates),
                  value: settings.ignoreCertificates,
                  onChanged: (value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setIgnoreCertificates(value ?? false);
                  },
                ),
                Divider(),
                CheckboxListTile(
                  title: Text(l10n.enableSentry),
                  subtitle: Text(l10n.sentryHelp),
                  value: settings.sentryEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setSentryEnabled(value ?? false);
                  },
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          controller: durationTextController,
                          decoration: InputDecoration(
                            labelText: l10n.backgroundRefreshInterval,
                            helperText: l10n.noLimitHelper,
                          ),
                        ),
                      ),
                      AppButton(
                        label: l10n.save,
                        variant: AppButtonVariant.tonal,
                        onPressed: () {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setRefreshInterval(
                                int.tryParse(
                                      durationTextController.value.text,
                                    ) ??
                                    0,
                              );
                        },
                      ),
                    ],
                  ),
                ),
                Divider(),
                CheckboxListTile(
                  title: Text(l10n.getVersionNotifications),
                  value: settings.versionNotifications,
                  onChanged: (value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setVersionNotifications(value ?? false);
                  },
                ),
                AppButton(
                  label: l10n.sendTestNotification,
                  variant: AppButtonVariant.tonal,
                  onPressed: () async {
                    var notifGranted = await Permission.notification.isGranted;
                    if (notifGranted) {
                      ref.read(notificationProvider)?.sendTestNotification();
                    } else {
                      var status = await Permission.notification.request();
                      if (status.isGranted) {
                        ref.read(notificationProvider)?.sendTestNotification();
                      } else if (status.isPermanentlyDenied &&
                          context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.noNotificationPermission),
                          ),
                        );
                      }
                    }
                  },
                ),
                AppButton(
                  label: l10n.checkForLatestVersion,
                  variant: AppButtonVariant.tonal,
                  onPressed: () async {
                    var newestVersion = await ref
                        .read(versionRepositoryProvider)
                        .getLatestVersionTag();
                    if (newestVersion == null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.versionCheckError)),
                      );
                    } else {
                      setState(() {
                        this.newestVersion = newestVersion;
                      });
                    }
                  },
                ),
                Text(
                  settings.currentVersion != null
                      ? l10n.currentVersionPrefix(
                          settings.currentVersion.toString(),
                        )
                      : l10n.currentVersionUnknown,
                ),
                Text(
                  newestVersion != null
                      ? l10n.latestVersionPrefix(newestVersion.toString())
                      : "",
                ),
                Divider(),
                AppButton(
                  label: l10n.logout,
                  variant: AppButtonVariant.danger,
                  onPressed: () async {
                    // Logout = lokale Wahrheitsquelle leeren, damit kein
                    // fremder Kontostand zurückbleibt. Currentuser wird über
                    // die LoginPage/Init neu gesetzt.
                    ref.read(currentUserProvider.notifier).clear();
                    await ref.read(appDatabaseProvider).wipeAll();
                    // Bild-Cache + pending_uploads physisch entfernen.
                    await ref.read(localFileStorageProvider).wipeAll();

                    await ref.read(settingsRepositoryProvider).saveServer(null);
                    await ref
                        .read(settingsRepositoryProvider)
                        .saveUserToken(null);
                    await ref
                        .read(settingsRepositoryProvider)
                        .saveRefreshToken(null);

                    if (!context.mounted) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (buildContext) => LoginPage()),
                    );
                  },
                ),
              ],
            );
          },
          error: (err, _) => VikunjaErrorWidget(
            error: err,
            onRetry: () => ref.invalidate(settingsControllerProvider),
          ),
          loading: () => const LoadingWidget(),
        ),
      ),
    );
  }

  Widget _buildUserHeader(
    WidgetRef ref,
    User user,
    List<Project> projects,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Profilkopf im To-Do-Stil: Foto der Anlage als Banner, darauf der
        // Avatar (antippen = Profilbild ändern) mit Name und Benutzername.
        SizedBox(
          height: 190,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/graphics/profile_header.jpg',
                fit: BoxFit.cover,
              ),
              // Abdunkeln, damit weiße Schrift auf jedem Bildbereich sitzt.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        UserAvatar(user: user, radius: 34),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.username,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Ganze Kopffläche antippbar: öffnet die Avatar-Auswahl.
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: () => _changeAvatar(ref, context)),
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).defaultProject),
          trailing: DropdownButton<int>(
            items: [
              DropdownMenuItem(
                value: 0,
                child: Text(AppLocalizations.of(context).none),
              ),
              ...projects.map(
                (e) => DropdownMenuItem(value: e.id, child: Text(e.title)),
              ),
            ],
            value:
                projects.firstWhereOrNull(
                      (element) =>
                          element.id == user.settings?.defaultProjectId,
                    ) !=
                    null
                ? user.settings?.defaultProjectId
                : 0,
            onChanged: (int? value) {
              if (value != null && user.settings != null) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setDefaultProject(value);
              }
            },
          ),
        ),
      ],
    );
  }

  /// Profilbild ändern (Vikunja-Avatar-API): Foto aufnehmen, aus der
  /// Mediathek wählen oder auf Initialen zurückstellen. Das Bild landet
  /// serverseitig — Web und alle Geräte zeigen es danach ebenfalls.
  Future<void> _changeAvatar(WidgetRef ref, BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showPresetSheet<String>(
      context,
      title: l10n.changeAvatar,
      options: [
        PresetOption(
          icon: Icons.photo_library_outlined,
          label: l10n.chooseFromLibrary,
          value: 'library',
        ),
        PresetOption(
          icon: Icons.photo_camera_outlined,
          label: l10n.takePhoto,
          value: 'camera',
        ),
        PresetOption(
          icon: Icons.person_outline,
          label: l10n.useInitials,
          value: 'initials',
        ),
      ],
    );
    if (choice == null || !context.mounted) return;

    final dataSource = ref.read(userDataSourceProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (choice == 'initials') {
      final res = await dataSource.setAvatarProvider('initials');
      await _afterAvatarChange(ref, messenger, l10n, res);
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (picked == null) return;

    final res = await dataSource.uploadAvatar(picked.path);
    if (res.isSuccessful) {
      // Vikunja setzt den Provider beim Upload nicht zwingend um — explizit
      // auf „upload" stellen, sonst liefert der Server weiter die Initialen.
      await dataSource.setAvatarProvider('upload');
    }
    await _afterAvatarChange(ref, messenger, l10n, res);
  }

  Future<void> _afterAvatarChange(
    WidgetRef ref,
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
    Response<Object> res,
  ) async {
    if (res.isSuccessful) {
      // Bild-Caches räumen und die Avatar-Version hochzählen (Cache-Buster
      // in der URL), damit das neue Bild sofort erscheint.
      imageCache.clear();
      imageCache.clearLiveImages();
      bumpAvatarVersion(ref);
      ref.invalidate(settingsControllerProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.avatarUpdated)));
    } else {
      // Statuscode mitgeben — sonst bleibt bei einem Serverfehler unklar,
      // woran es lag.
      final detail = res is ErrorResponse<Object>
          ? ' (HTTP ${res.statusCode})'
          : '';
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.avatarUpdateError}$detail')),
      );
    }
  }
}
