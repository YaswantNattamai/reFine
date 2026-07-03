// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locked_app.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLockedAppCollection on Isar {
  IsarCollection<LockedApp> get lockedApps => this.collection();
}

const LockedAppSchema = CollectionSchema(
  name: r'LockedApp',
  id: 43851188898896387,
  properties: {
    r'bypassUntil': PropertySchema(
      id: 0,
      name: r'bypassUntil',
      type: IsarType.dateTime,
    ),
    r'dailyLimitMinutes': PropertySchema(
      id: 1,
      name: r'dailyLimitMinutes',
      type: IsarType.long,
    ),
    r'lastResetDate': PropertySchema(
      id: 2,
      name: r'lastResetDate',
      type: IsarType.dateTime,
    ),
    r'packageName': PropertySchema(
      id: 3,
      name: r'packageName',
      type: IsarType.string,
    ),
    r'todayUsageMinutes': PropertySchema(
      id: 4,
      name: r'todayUsageMinutes',
      type: IsarType.long,
    )
  },
  estimateSize: _lockedAppEstimateSize,
  serialize: _lockedAppSerialize,
  deserialize: _lockedAppDeserialize,
  deserializeProp: _lockedAppDeserializeProp,
  idName: r'id',
  indexes: {
    r'packageName': IndexSchema(
      id: -3211024755902609907,
      name: r'packageName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'packageName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _lockedAppGetId,
  getLinks: _lockedAppGetLinks,
  attach: _lockedAppAttach,
  version: '3.1.0+1',
);

int _lockedAppEstimateSize(
  LockedApp object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.packageName.length * 3;
  return bytesCount;
}

void _lockedAppSerialize(
  LockedApp object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.bypassUntil);
  writer.writeLong(offsets[1], object.dailyLimitMinutes);
  writer.writeDateTime(offsets[2], object.lastResetDate);
  writer.writeString(offsets[3], object.packageName);
  writer.writeLong(offsets[4], object.todayUsageMinutes);
}

LockedApp _lockedAppDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LockedApp();
  object.bypassUntil = reader.readDateTimeOrNull(offsets[0]);
  object.dailyLimitMinutes = reader.readLong(offsets[1]);
  object.id = id;
  object.lastResetDate = reader.readDateTimeOrNull(offsets[2]);
  object.packageName = reader.readString(offsets[3]);
  object.todayUsageMinutes = reader.readLong(offsets[4]);
  return object;
}

P _lockedAppDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lockedAppGetId(LockedApp object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lockedAppGetLinks(LockedApp object) {
  return [];
}

void _lockedAppAttach(IsarCollection<dynamic> col, Id id, LockedApp object) {
  object.id = id;
}

extension LockedAppByIndex on IsarCollection<LockedApp> {
  Future<LockedApp?> getByPackageName(String packageName) {
    return getByIndex(r'packageName', [packageName]);
  }

  LockedApp? getByPackageNameSync(String packageName) {
    return getByIndexSync(r'packageName', [packageName]);
  }

  Future<bool> deleteByPackageName(String packageName) {
    return deleteByIndex(r'packageName', [packageName]);
  }

  bool deleteByPackageNameSync(String packageName) {
    return deleteByIndexSync(r'packageName', [packageName]);
  }

  Future<List<LockedApp?>> getAllByPackageName(List<String> packageNameValues) {
    final values = packageNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'packageName', values);
  }

  List<LockedApp?> getAllByPackageNameSync(List<String> packageNameValues) {
    final values = packageNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'packageName', values);
  }

  Future<int> deleteAllByPackageName(List<String> packageNameValues) {
    final values = packageNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'packageName', values);
  }

  int deleteAllByPackageNameSync(List<String> packageNameValues) {
    final values = packageNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'packageName', values);
  }

  Future<Id> putByPackageName(LockedApp object) {
    return putByIndex(r'packageName', object);
  }

  Id putByPackageNameSync(LockedApp object, {bool saveLinks = true}) {
    return putByIndexSync(r'packageName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPackageName(List<LockedApp> objects) {
    return putAllByIndex(r'packageName', objects);
  }

  List<Id> putAllByPackageNameSync(List<LockedApp> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'packageName', objects, saveLinks: saveLinks);
  }
}

extension LockedAppQueryWhereSort
    on QueryBuilder<LockedApp, LockedApp, QWhere> {
  QueryBuilder<LockedApp, LockedApp, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LockedAppQueryWhere
    on QueryBuilder<LockedApp, LockedApp, QWhereClause> {
  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> packageNameEqualTo(
      String packageName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packageName',
        value: [packageName],
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterWhereClause> packageNameNotEqualTo(
      String packageName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [],
              upper: [packageName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [packageName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [packageName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [],
              upper: [packageName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LockedAppQueryFilter
    on QueryBuilder<LockedApp, LockedApp, QFilterCondition> {
  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      bypassUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bypassUntil',
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      bypassUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bypassUntil',
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> bypassUntilEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bypassUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      bypassUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bypassUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> bypassUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bypassUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> bypassUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bypassUntil',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      dailyLimitMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      dailyLimitMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      dailyLimitMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      dailyLimitMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyLimitMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      lastResetDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastResetDate',
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      lastResetDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastResetDate',
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      lastResetDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastResetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      lastResetDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastResetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      lastResetDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastResetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      lastResetDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastResetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> packageNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      packageNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> packageNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> packageNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packageName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      packageNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> packageNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> packageNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition> packageNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packageName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      packageNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packageName',
        value: '',
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      packageNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packageName',
        value: '',
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      todayUsageMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'todayUsageMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      todayUsageMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'todayUsageMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      todayUsageMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'todayUsageMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterFilterCondition>
      todayUsageMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'todayUsageMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LockedAppQueryObject
    on QueryBuilder<LockedApp, LockedApp, QFilterCondition> {}

extension LockedAppQueryLinks
    on QueryBuilder<LockedApp, LockedApp, QFilterCondition> {}

extension LockedAppQuerySortBy on QueryBuilder<LockedApp, LockedApp, QSortBy> {
  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByBypassUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassUntil', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByBypassUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassUntil', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy>
      sortByDailyLimitMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByLastResetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByLastResetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByPackageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByPackageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> sortByTodayUsageMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayUsageMinutes', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy>
      sortByTodayUsageMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayUsageMinutes', Sort.desc);
    });
  }
}

extension LockedAppQuerySortThenBy
    on QueryBuilder<LockedApp, LockedApp, QSortThenBy> {
  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByBypassUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassUntil', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByBypassUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassUntil', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy>
      thenByDailyLimitMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByLastResetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByLastResetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByPackageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByPackageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.desc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy> thenByTodayUsageMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayUsageMinutes', Sort.asc);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QAfterSortBy>
      thenByTodayUsageMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayUsageMinutes', Sort.desc);
    });
  }
}

extension LockedAppQueryWhereDistinct
    on QueryBuilder<LockedApp, LockedApp, QDistinct> {
  QueryBuilder<LockedApp, LockedApp, QDistinct> distinctByBypassUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bypassUntil');
    });
  }

  QueryBuilder<LockedApp, LockedApp, QDistinct> distinctByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyLimitMinutes');
    });
  }

  QueryBuilder<LockedApp, LockedApp, QDistinct> distinctByLastResetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastResetDate');
    });
  }

  QueryBuilder<LockedApp, LockedApp, QDistinct> distinctByPackageName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packageName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LockedApp, LockedApp, QDistinct> distinctByTodayUsageMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'todayUsageMinutes');
    });
  }
}

extension LockedAppQueryProperty
    on QueryBuilder<LockedApp, LockedApp, QQueryProperty> {
  QueryBuilder<LockedApp, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LockedApp, DateTime?, QQueryOperations> bypassUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bypassUntil');
    });
  }

  QueryBuilder<LockedApp, int, QQueryOperations> dailyLimitMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyLimitMinutes');
    });
  }

  QueryBuilder<LockedApp, DateTime?, QQueryOperations> lastResetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastResetDate');
    });
  }

  QueryBuilder<LockedApp, String, QQueryOperations> packageNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packageName');
    });
  }

  QueryBuilder<LockedApp, int, QQueryOperations> todayUsageMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'todayUsageMinutes');
    });
  }
}
