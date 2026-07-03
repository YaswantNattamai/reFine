// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsCollection on Isar {
  IsarCollection<Settings> get settings => this.collection();
}

const SettingsSchema = CollectionSchema(
  name: r'Settings',
  id: -8656046621518759136,
  properties: {
    r'defaultLauncher': PropertySchema(
      id: 0,
      name: r'defaultLauncher',
      type: IsarType.bool,
    ),
    r'favoriteApps': PropertySchema(
      id: 1,
      name: r'favoriteApps',
      type: IsarType.stringList,
    ),
    r'quoteEnabled': PropertySchema(
      id: 2,
      name: r'quoteEnabled',
      type: IsarType.bool,
    ),
    r'selectedWallpaperPath': PropertySchema(
      id: 3,
      name: r'selectedWallpaperPath',
      type: IsarType.string,
    ),
    r'wallpaperUnlockedThreshold': PropertySchema(
      id: 4,
      name: r'wallpaperUnlockedThreshold',
      type: IsarType.double,
    )
  },
  estimateSize: _settingsEstimateSize,
  serialize: _settingsSerialize,
  deserialize: _settingsDeserialize,
  deserializeProp: _settingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsGetId,
  getLinks: _settingsGetLinks,
  attach: _settingsAttach,
  version: '3.1.0+1',
);

int _settingsEstimateSize(
  Settings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.favoriteApps.length * 3;
  {
    for (var i = 0; i < object.favoriteApps.length; i++) {
      final value = object.favoriteApps[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.selectedWallpaperPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _settingsSerialize(
  Settings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.defaultLauncher);
  writer.writeStringList(offsets[1], object.favoriteApps);
  writer.writeBool(offsets[2], object.quoteEnabled);
  writer.writeString(offsets[3], object.selectedWallpaperPath);
  writer.writeDouble(offsets[4], object.wallpaperUnlockedThreshold);
}

Settings _settingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Settings();
  object.defaultLauncher = reader.readBool(offsets[0]);
  object.favoriteApps = reader.readStringList(offsets[1]) ?? [];
  object.id = id;
  object.quoteEnabled = reader.readBool(offsets[2]);
  object.selectedWallpaperPath = reader.readStringOrNull(offsets[3]);
  object.wallpaperUnlockedThreshold = reader.readDouble(offsets[4]);
  return object;
}

P _settingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _settingsGetId(Settings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsGetLinks(Settings object) {
  return [];
}

void _settingsAttach(IsarCollection<dynamic> col, Id id, Settings object) {
  object.id = id;
}

extension SettingsQueryWhereSort on QueryBuilder<Settings, Settings, QWhere> {
  QueryBuilder<Settings, Settings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsQueryWhere on QueryBuilder<Settings, Settings, QWhereClause> {
  QueryBuilder<Settings, Settings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Settings, Settings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idBetween(
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
}

extension SettingsQueryFilter
    on QueryBuilder<Settings, Settings, QFilterCondition> {
  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      defaultLauncherEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultLauncher',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'favoriteApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'favoriteApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'favoriteApps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'favoriteApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'favoriteApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'favoriteApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'favoriteApps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteApps',
        value: '',
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'favoriteApps',
        value: '',
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteApps',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteApps',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteApps',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteApps',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteApps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      favoriteAppsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteApps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Settings, Settings, QAfterFilterCondition> quoteEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quoteEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'selectedWallpaperPath',
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'selectedWallpaperPath',
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedWallpaperPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedWallpaperPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedWallpaperPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedWallpaperPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'selectedWallpaperPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'selectedWallpaperPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedWallpaperPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedWallpaperPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedWallpaperPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      selectedWallpaperPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedWallpaperPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      wallpaperUnlockedThresholdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wallpaperUnlockedThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      wallpaperUnlockedThresholdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wallpaperUnlockedThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      wallpaperUnlockedThresholdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wallpaperUnlockedThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      wallpaperUnlockedThresholdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wallpaperUnlockedThreshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension SettingsQueryObject
    on QueryBuilder<Settings, Settings, QFilterCondition> {}

extension SettingsQueryLinks
    on QueryBuilder<Settings, Settings, QFilterCondition> {}

extension SettingsQuerySortBy on QueryBuilder<Settings, Settings, QSortBy> {
  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultLauncher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLauncher', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultLauncherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLauncher', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByQuoteEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quoteEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByQuoteEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quoteEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortBySelectedWallpaperPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWallpaperPath', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortBySelectedWallpaperPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWallpaperPath', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortByWallpaperUnlockedThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallpaperUnlockedThreshold', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortByWallpaperUnlockedThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallpaperUnlockedThreshold', Sort.desc);
    });
  }
}

extension SettingsQuerySortThenBy
    on QueryBuilder<Settings, Settings, QSortThenBy> {
  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultLauncher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLauncher', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultLauncherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLauncher', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByQuoteEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quoteEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByQuoteEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quoteEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenBySelectedWallpaperPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWallpaperPath', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenBySelectedWallpaperPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWallpaperPath', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenByWallpaperUnlockedThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallpaperUnlockedThreshold', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenByWallpaperUnlockedThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallpaperUnlockedThreshold', Sort.desc);
    });
  }
}

extension SettingsQueryWhereDistinct
    on QueryBuilder<Settings, Settings, QDistinct> {
  QueryBuilder<Settings, Settings, QDistinct> distinctByDefaultLauncher() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultLauncher');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByFavoriteApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favoriteApps');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByQuoteEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quoteEnabled');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctBySelectedWallpaperPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedWallpaperPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
      distinctByWallpaperUnlockedThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wallpaperUnlockedThreshold');
    });
  }
}

extension SettingsQueryProperty
    on QueryBuilder<Settings, Settings, QQueryProperty> {
  QueryBuilder<Settings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> defaultLauncherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultLauncher');
    });
  }

  QueryBuilder<Settings, List<String>, QQueryOperations>
      favoriteAppsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoriteApps');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> quoteEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quoteEnabled');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations>
      selectedWallpaperPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedWallpaperPath');
    });
  }

  QueryBuilder<Settings, double, QQueryOperations>
      wallpaperUnlockedThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wallpaperUnlockedThreshold');
    });
  }
}
