// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskPageControllerHash() =>
    r'f23fd5dc9beed9efa579eacfd4ab4cd6efbe2201';

/// Übersicht (Landing-Page). Standardfälle (offene Tasks, optional nur mit
/// Fälligkeit) kommen reaktiv aus der DB. Ein benutzerdefinierter Übersichts-
/// Filter (filter_id) wird online geladen; schlägt das fehl (offline), fällt
/// er auf den DB-Standard zurück (lokaler Filter-Evaluator kommt in M3).
///
/// Copied from [TaskPageController].
@ProviderFor(TaskPageController)
final taskPageControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      TaskPageController,
      TaskPageModel
    >.internal(
      TaskPageController.new,
      name: r'taskPageControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskPageControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskPageController = AutoDisposeAsyncNotifier<TaskPageModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
