// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$projectsControllerHash() =>
    r'58841b74964d783bccf377a375429e194d0220ac';

/// Liest die Projektliste reaktiv aus der lokalen DB (watch-Stream). Schreib-
/// Methoden gehen weiterhin über die Repositories (Online-API) und upserten
/// die Server-Antwort in die DB; die UI aktualisiert sich über den Stream.
///
/// Copied from [ProjectsController].
@ProviderFor(ProjectsController)
final projectsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ProjectsController,
      ProjectListModel
    >.internal(
      ProjectsController.new,
      name: r'projectsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$projectsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProjectsController = AutoDisposeAsyncNotifier<ProjectListModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
