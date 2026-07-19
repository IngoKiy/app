// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localFileStorageHash() => r'948eea75eea5cfbe390b3bfae948b3cd12184a98';

/// Kapselt die auf der Platte liegenden Local-First-Verzeichnisse.
///
/// Copied from [localFileStorage].
@ProviderFor(localFileStorage)
final localFileStorageProvider = Provider<LocalFileStorage>.internal(
  localFileStorage,
  name: r'localFileStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localFileStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalFileStorageRef = ProviderRef<LocalFileStorage>;
String _$imageDiskCacheHash() => r'e4d219c90708c5484009f474130957c557ea2621';

/// Platten-Cache für authentifizierte Bilder. Beim ersten Zugriff wird eine
/// Eviction (Alter/Größe) angestoßen.
///
/// Copied from [imageDiskCache].
@ProviderFor(imageDiskCache)
final imageDiskCacheProvider = Provider<ImageDiskCache>.internal(
  imageDiskCache,
  name: r'imageDiskCacheProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageDiskCacheHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImageDiskCacheRef = ProviderRef<ImageDiskCache>;
String _$attachmentPrefetcherHash() =>
    r'29f9505aa39bf15d448975d5c53612d1354cf795';

/// Lädt Anhänge synchronisierter Tasks automatisch on-device (Offline-
/// Verfügbarkeit). Wird über [SyncService.onPullCompleted] nach jedem Pull
/// angestoßen.
///
/// Copied from [attachmentPrefetcher].
@ProviderFor(attachmentPrefetcher)
final attachmentPrefetcherProvider = Provider<AttachmentPrefetcher>.internal(
  attachmentPrefetcher,
  name: r'attachmentPrefetcherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attachmentPrefetcherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentPrefetcherRef = ProviderRef<AttachmentPrefetcher>;
String _$tempIdAllocatorHash() => r'6b178b8018fe902457ea99a7b6c605eef8b2fccb';

/// See also [tempIdAllocator].
@ProviderFor(tempIdAllocator)
final tempIdAllocatorProvider = Provider<TempIdAllocator>.internal(
  tempIdAllocator,
  name: r'tempIdAllocatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tempIdAllocatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TempIdAllocatorRef = ProviderRef<TempIdAllocator>;
String _$pendingOpsCountHash() => r'fc67800393488c82242036ee6f65f94aa8113784';

/// Reaktive Anzahl offener Outbox-Ops.
///
/// Copied from [pendingOpsCount].
@ProviderFor(pendingOpsCount)
final pendingOpsCountProvider = StreamProvider<int>.internal(
  pendingOpsCount,
  name: r'pendingOpsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingOpsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOpsCountRef = StreamProviderRef<int>;
String _$pendingOpsListHash() => r'2b915fcefb07bd0c97cb2928f83dd227701f5fe5';

/// Reaktive Gesamtliste der Outbox-Ops (für das Sync-Status-Sheet).
///
/// Copied from [pendingOpsList].
@ProviderFor(pendingOpsList)
final pendingOpsListProvider =
    AutoDisposeStreamProvider<List<PendingOp>>.internal(
      pendingOpsList,
      name: r'pendingOpsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingOpsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOpsListRef = AutoDisposeStreamProviderRef<List<PendingOp>>;
String _$outboxHash() => r'410d33ba17391cac792b6a818c9ab2965a14d143';

/// Schreibende Outbox-Fassade. Spiegelt zusätzlich den pending-Zähler aus dem
/// DAO-watch in den [SyncStateNotifier] (setPendingOps).
///
/// Copied from [outbox].
@ProviderFor(outbox)
final outboxProvider = Provider<Outbox>.internal(
  outbox,
  name: r'outboxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$outboxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OutboxRef = ProviderRef<Outbox>;
String _$opExecutorHash() => r'a33ad5b460479ba3bc1aa355c4427978dea13579';

/// Geteilter Sende-/Migrations-Kern für Push und optimistische Writes.
///
/// Copied from [opExecutor].
@ProviderFor(opExecutor)
final opExecutorProvider = Provider<OpExecutor>.internal(
  opExecutor,
  name: r'opExecutorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$opExecutorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpExecutorRef = ProviderRef<OpExecutor>;
String _$offlineWriterHash() => r'52789fced5dfa16731e914c4e937d722d1d0e4c0';

/// Zentrale Fassade für alle schreibenden Operationen (local-first + Outbox).
///
/// Copied from [offlineWriter].
@ProviderFor(offlineWriter)
final offlineWriterProvider = Provider<OfflineWriter>.internal(
  offlineWriter,
  name: r'offlineWriterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offlineWriterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineWriterRef = ProviderRef<OfflineWriter>;
String _$pushProcessorHash() => r'74ebdb0ef59a9290cee51660759c48d2b2fe2b4e';

/// See also [pushProcessor].
@ProviderFor(pushProcessor)
final pushProcessorProvider = Provider<PushProcessor>.internal(
  pushProcessor,
  name: r'pushProcessorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pushProcessorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushProcessorRef = ProviderRef<PushProcessor>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
