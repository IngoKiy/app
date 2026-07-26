// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$smartListTasksHash() => r'6275575e1d16415225b82bb97a0a4a3f8f9de4e1';

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

/// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
/// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
/// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
///
/// Copied from [smartListTasks].
@ProviderFor(smartListTasks)
const smartListTasksProvider = SmartListTasksFamily();

/// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
/// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
/// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
///
/// Copied from [smartListTasks].
class SmartListTasksFamily extends Family<AsyncValue<List<Task>>> {
  /// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
  /// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
  /// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
  ///
  /// Copied from [smartListTasks].
  const SmartListTasksFamily();

  /// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
  /// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
  /// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
  ///
  /// Copied from [smartListTasks].
  SmartListTasksProvider call(SmartList list) {
    return SmartListTasksProvider(list);
  }

  @override
  SmartListTasksProvider getProviderOverride(
    covariant SmartListTasksProvider provider,
  ) {
    return call(provider.list);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'smartListTasksProvider';
}

/// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
/// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
/// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
///
/// Copied from [smartListTasks].
class SmartListTasksProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
  /// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
  /// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
  ///
  /// Copied from [smartListTasks].
  SmartListTasksProvider(SmartList list)
    : this._internal(
        (ref) => smartListTasks(ref as SmartListTasksRef, list),
        from: smartListTasksProvider,
        name: r'smartListTasksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$smartListTasksHash,
        dependencies: SmartListTasksFamily._dependencies,
        allTransitiveDependencies:
            SmartListTasksFamily._allTransitiveDependencies,
        list: list,
      );

  SmartListTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.list,
  }) : super.internal();

  final SmartList list;

  @override
  Override overrideWith(
    Stream<List<Task>> Function(SmartListTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SmartListTasksProvider._internal(
        (ref) => create(ref as SmartListTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        list: list,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _SmartListTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SmartListTasksProvider && other.list == list;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, list.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SmartListTasksRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `list` of this provider.
  SmartList get list;
}

class _SmartListTasksProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>>
    with SmartListTasksRef {
  _SmartListTasksProviderElement(super.provider);

  @override
  SmartList get list => (origin as SmartListTasksProvider).list;
}

String _$smartListCountHash() => r'f6af5746b0f6ce09b18fd097debc585d9ec729f7';

/// Zähler einer [SmartList] für die Listen-Übersicht.
///
/// Copied from [smartListCount].
@ProviderFor(smartListCount)
const smartListCountProvider = SmartListCountFamily();

/// Zähler einer [SmartList] für die Listen-Übersicht.
///
/// Copied from [smartListCount].
class SmartListCountFamily extends Family<AsyncValue<int>> {
  /// Zähler einer [SmartList] für die Listen-Übersicht.
  ///
  /// Copied from [smartListCount].
  const SmartListCountFamily();

  /// Zähler einer [SmartList] für die Listen-Übersicht.
  ///
  /// Copied from [smartListCount].
  SmartListCountProvider call(SmartList list) {
    return SmartListCountProvider(list);
  }

  @override
  SmartListCountProvider getProviderOverride(
    covariant SmartListCountProvider provider,
  ) {
    return call(provider.list);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'smartListCountProvider';
}

/// Zähler einer [SmartList] für die Listen-Übersicht.
///
/// Copied from [smartListCount].
class SmartListCountProvider extends AutoDisposeStreamProvider<int> {
  /// Zähler einer [SmartList] für die Listen-Übersicht.
  ///
  /// Copied from [smartListCount].
  SmartListCountProvider(SmartList list)
    : this._internal(
        (ref) => smartListCount(ref as SmartListCountRef, list),
        from: smartListCountProvider,
        name: r'smartListCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$smartListCountHash,
        dependencies: SmartListCountFamily._dependencies,
        allTransitiveDependencies:
            SmartListCountFamily._allTransitiveDependencies,
        list: list,
      );

  SmartListCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.list,
  }) : super.internal();

  final SmartList list;

  @override
  Override overrideWith(
    Stream<int> Function(SmartListCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SmartListCountProvider._internal(
        (ref) => create(ref as SmartListCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        list: list,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _SmartListCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SmartListCountProvider && other.list == list;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, list.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SmartListCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `list` of this provider.
  SmartList get list;
}

class _SmartListCountProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with SmartListCountRef {
  _SmartListCountProviderElement(super.provider);

  @override
  SmartList get list => (origin as SmartListCountProvider).list;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
