// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$projectControllerHash() => r'7c046c239222e2bf61818f3e146331d816beb90f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ProjectController
    extends BuildlessAutoDisposeAsyncNotifier<ProjectPageModel> {
  late final Project project;

  FutureOr<ProjectPageModel> build(Project project);
}

/// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
/// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
/// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
///
/// Copied from [ProjectController].
@ProviderFor(ProjectController)
const projectControllerProvider = ProjectControllerFamily();

/// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
/// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
/// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
///
/// Copied from [ProjectController].
class ProjectControllerFamily extends Family<AsyncValue<ProjectPageModel>> {
  /// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
  /// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
  /// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
  ///
  /// Copied from [ProjectController].
  const ProjectControllerFamily();

  /// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
  /// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
  /// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
  ///
  /// Copied from [ProjectController].
  ProjectControllerProvider call(Project project) {
    return ProjectControllerProvider(project);
  }

  @override
  ProjectControllerProvider getProviderOverride(
    covariant ProjectControllerProvider provider,
  ) {
    return call(provider.project);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectControllerProvider';
}

/// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
/// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
/// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
///
/// Copied from [ProjectController].
class ProjectControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ProjectController,
          ProjectPageModel
        > {
  /// Liest Liste bzw. Kanban-Buckets reaktiv aus der lokalen DB (watch-Streams).
  /// Schreib-Methoden gehen weiterhin über die Repositories (Online-API) und
  /// upserten die Server-Antwort in die DB; die UI aktualisiert sich per Stream.
  ///
  /// Copied from [ProjectController].
  ProjectControllerProvider(Project project)
    : this._internal(
        () => ProjectController()..project = project,
        from: projectControllerProvider,
        name: r'projectControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$projectControllerHash,
        dependencies: ProjectControllerFamily._dependencies,
        allTransitiveDependencies:
            ProjectControllerFamily._allTransitiveDependencies,
        project: project,
      );

  ProjectControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.project,
  }) : super.internal();

  final Project project;

  @override
  FutureOr<ProjectPageModel> runNotifierBuild(
    covariant ProjectController notifier,
  ) {
    return notifier.build(project);
  }

  @override
  Override overrideWith(ProjectController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProjectControllerProvider._internal(
        () => create()..project = project,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        project: project,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProjectController, ProjectPageModel>
  createElement() {
    return _ProjectControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectControllerProvider && other.project == project;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, project.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ProjectPageModel> {
  /// The parameter `project` of this provider.
  Project get project;
}

class _ProjectControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ProjectController,
          ProjectPageModel
        >
    with ProjectControllerRef {
  _ProjectControllerProviderElement(super.provider);

  @override
  Project get project => (origin as ProjectControllerProvider).project;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
