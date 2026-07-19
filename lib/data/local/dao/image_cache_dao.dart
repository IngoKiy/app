import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/image_cache_table.dart';

part 'image_cache_dao.g.dart';

@DriftAccessor(tables: [ImageCaches])
class ImageCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ImageCacheDaoMixin {
  ImageCacheDao(super.db);

  Future<ImageCacheRow?> getByHash(String urlHash) =>
      (select(imageCaches)..where((i) => i.urlHash.equals(urlHash)))
          .getSingleOrNull();

  /// Alle Registry-Einträge, älteste (nach `fetchedAt`) zuerst — Grundlage der
  /// Eviction.
  Future<List<ImageCacheRow>> getAllOldestFirst() =>
      (select(imageCaches)..orderBy([(i) => OrderingTerm.asc(i.fetchedAt)]))
          .get();

  Future<void> put(ImageCachesCompanion data) =>
      into(imageCaches).insertOnConflictUpdate(data);

  Future<void> remove(String urlHash) =>
      (delete(imageCaches)..where((i) => i.urlHash.equals(urlHash))).go();

  Future<int> wipeAll() => delete(imageCaches).go();
}
