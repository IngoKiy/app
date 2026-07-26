// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listSortModeHash() => r'b9e41942e938343d5da584767dbf00e2aa01b137';

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

/// Persistierter Sortier-Modus einer Liste. [listKey] ist `smart/<name>` für
/// Smart-Lists bzw. `project/<id>` für Projekte.
///
/// Copied from [listSortMode].
@ProviderFor(listSortMode)
const listSortModeProvider = ListSortModeFamily();

/// Persistierter Sortier-Modus einer Liste. [listKey] ist `smart/<name>` für
/// Smart-Lists bzw. `project/<id>` für Projekte.
///
/// Copied from [listSortMode].
class ListSortModeFamily extends Family<AsyncValue<TaskSortMode>> {
  /// Persistierter Sortier-Modus einer Liste. [listKey] ist `smart/<name>` für
  /// Smart-Lists bzw. `project/<id>` für Projekte.
  ///
  /// Copied from [listSortMode].
  const ListSortModeFamily();

  /// Persistierter Sortier-Modus einer Liste. [listKey] ist `smart/<name>` für
  /// Smart-Lists bzw. `project/<id>` für Projekte.
  ///
  /// Copied from [listSortMode].
  ListSortModeProvider call(String listKey) {
    return ListSortModeProvider(listKey);
  }

  @override
  ListSortModeProvider getProviderOverride(
    covariant ListSortModeProvider provider,
  ) {
    return call(provider.listKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listSortModeProvider';
}

/// Persistierter Sortier-Modus einer Liste. [listKey] ist `smart/<name>` für
/// Smart-Lists bzw. `project/<id>` für Projekte.
///
/// Copied from [listSortMode].
class ListSortModeProvider extends AutoDisposeStreamProvider<TaskSortMode> {
  /// Persistierter Sortier-Modus einer Liste. [listKey] ist `smart/<name>` für
  /// Smart-Lists bzw. `project/<id>` für Projekte.
  ///
  /// Copied from [listSortMode].
  ListSortModeProvider(String listKey)
    : this._internal(
        (ref) => listSortMode(ref as ListSortModeRef, listKey),
        from: listSortModeProvider,
        name: r'listSortModeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listSortModeHash,
        dependencies: ListSortModeFamily._dependencies,
        allTransitiveDependencies:
            ListSortModeFamily._allTransitiveDependencies,
        listKey: listKey,
      );

  ListSortModeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listKey,
  }) : super.internal();

  final String listKey;

  @override
  Override overrideWith(
    Stream<TaskSortMode> Function(ListSortModeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListSortModeProvider._internal(
        (ref) => create(ref as ListSortModeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listKey: listKey,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<TaskSortMode> createElement() {
    return _ListSortModeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListSortModeProvider && other.listKey == listKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListSortModeRef on AutoDisposeStreamProviderRef<TaskSortMode> {
  /// The parameter `listKey` of this provider.
  String get listKey;
}

class _ListSortModeProviderElement
    extends AutoDisposeStreamProviderElement<TaskSortMode>
    with ListSortModeRef {
  _ListSortModeProviderElement(super.provider);

  @override
  String get listKey => (origin as ListSortModeProvider).listKey;
}

String _$smartListTasksHash() => r'746bc1c21a912eb45cef8b56c39165c0469eb099';

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

String _$smartListCountHash() => r'8e646ccc6397b4ee574f5f97f9dd8e711180a9b0';

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

String _$taskInMyDayHash() => r'268c5873d50fee6509ea1694c6210e27976ac60f';

/// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
///
/// Copied from [taskInMyDay].
@ProviderFor(taskInMyDay)
const taskInMyDayProvider = TaskInMyDayFamily();

/// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
///
/// Copied from [taskInMyDay].
class TaskInMyDayFamily extends Family<AsyncValue<bool>> {
  /// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
  ///
  /// Copied from [taskInMyDay].
  const TaskInMyDayFamily();

  /// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
  ///
  /// Copied from [taskInMyDay].
  TaskInMyDayProvider call(int taskId) {
    return TaskInMyDayProvider(taskId);
  }

  @override
  TaskInMyDayProvider getProviderOverride(
    covariant TaskInMyDayProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskInMyDayProvider';
}

/// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
///
/// Copied from [taskInMyDay].
class TaskInMyDayProvider extends AutoDisposeStreamProvider<bool> {
  /// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
  ///
  /// Copied from [taskInMyDay].
  TaskInMyDayProvider(int taskId)
    : this._internal(
        (ref) => taskInMyDay(ref as TaskInMyDayRef, taskId),
        from: taskInMyDayProvider,
        name: r'taskInMyDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskInMyDayHash,
        dependencies: TaskInMyDayFamily._dependencies,
        allTransitiveDependencies: TaskInMyDayFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskInMyDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  Override overrideWith(Stream<bool> Function(TaskInMyDayRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TaskInMyDayProvider._internal(
        (ref) => create(ref as TaskInMyDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _TaskInMyDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskInMyDayProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskInMyDayRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _TaskInMyDayProviderElement extends AutoDisposeStreamProviderElement<bool>
    with TaskInMyDayRef {
  _TaskInMyDayProviderElement(super.provider);

  @override
  int get taskId => (origin as TaskInMyDayProvider).taskId;
}

String _$taskSearchHash() => r'19fdddc046b5c9fe0c5d35aed231d47695239c39';

/// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
///
/// Copied from [taskSearch].
@ProviderFor(taskSearch)
const taskSearchProvider = TaskSearchFamily();

/// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
///
/// Copied from [taskSearch].
class TaskSearchFamily extends Family<AsyncValue<List<Task>>> {
  /// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
  ///
  /// Copied from [taskSearch].
  const TaskSearchFamily();

  /// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
  ///
  /// Copied from [taskSearch].
  TaskSearchProvider call(String query) {
    return TaskSearchProvider(query);
  }

  @override
  TaskSearchProvider getProviderOverride(
    covariant TaskSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskSearchProvider';
}

/// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
///
/// Copied from [taskSearch].
class TaskSearchProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
  ///
  /// Copied from [taskSearch].
  TaskSearchProvider(String query)
    : this._internal(
        (ref) => taskSearch(ref as TaskSearchRef, query),
        from: taskSearchProvider,
        name: r'taskSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskSearchHash,
        dependencies: TaskSearchFamily._dependencies,
        allTransitiveDependencies: TaskSearchFamily._allTransitiveDependencies,
        query: query,
      );

  TaskSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    Stream<List<Task>> Function(TaskSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskSearchProvider._internal(
        (ref) => create(ref as TaskSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _TaskSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskSearchRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _TaskSearchProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>>
    with TaskSearchRef {
  _TaskSearchProviderElement(super.provider);

  @override
  String get query => (origin as TaskSearchProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
