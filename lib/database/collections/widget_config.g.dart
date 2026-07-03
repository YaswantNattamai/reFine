// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWidgetConfigCollection on Isar {
  IsarCollection<WidgetConfig> get widgetConfigs => this.collection();
}

const WidgetConfigSchema = CollectionSchema(
  name: r'WidgetConfig',
  id: 8032972480673106194,
  properties: {
    r'height': PropertySchema(
      id: 0,
      name: r'height',
      type: IsarType.double,
    ),
    r'isVisible': PropertySchema(
      id: 1,
      name: r'isVisible',
      type: IsarType.bool,
    ),
    r'position': PropertySchema(
      id: 2,
      name: r'position',
      type: IsarType.long,
    ),
    r'widgetType': PropertySchema(
      id: 3,
      name: r'widgetType',
      type: IsarType.string,
    )
  },
  estimateSize: _widgetConfigEstimateSize,
  serialize: _widgetConfigSerialize,
  deserialize: _widgetConfigDeserialize,
  deserializeProp: _widgetConfigDeserializeProp,
  idName: r'id',
  indexes: {
    r'widgetType': IndexSchema(
      id: -40241655692754270,
      name: r'widgetType',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'widgetType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _widgetConfigGetId,
  getLinks: _widgetConfigGetLinks,
  attach: _widgetConfigAttach,
  version: '3.1.0+1',
);

int _widgetConfigEstimateSize(
  WidgetConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.widgetType.length * 3;
  return bytesCount;
}

void _widgetConfigSerialize(
  WidgetConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.height);
  writer.writeBool(offsets[1], object.isVisible);
  writer.writeLong(offsets[2], object.position);
  writer.writeString(offsets[3], object.widgetType);
}

WidgetConfig _widgetConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WidgetConfig();
  object.height = reader.readDouble(offsets[0]);
  object.id = id;
  object.isVisible = reader.readBool(offsets[1]);
  object.position = reader.readLong(offsets[2]);
  object.widgetType = reader.readString(offsets[3]);
  return object;
}

P _widgetConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _widgetConfigGetId(WidgetConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _widgetConfigGetLinks(WidgetConfig object) {
  return [];
}

void _widgetConfigAttach(
    IsarCollection<dynamic> col, Id id, WidgetConfig object) {
  object.id = id;
}

extension WidgetConfigByIndex on IsarCollection<WidgetConfig> {
  Future<WidgetConfig?> getByWidgetType(String widgetType) {
    return getByIndex(r'widgetType', [widgetType]);
  }

  WidgetConfig? getByWidgetTypeSync(String widgetType) {
    return getByIndexSync(r'widgetType', [widgetType]);
  }

  Future<bool> deleteByWidgetType(String widgetType) {
    return deleteByIndex(r'widgetType', [widgetType]);
  }

  bool deleteByWidgetTypeSync(String widgetType) {
    return deleteByIndexSync(r'widgetType', [widgetType]);
  }

  Future<List<WidgetConfig?>> getAllByWidgetType(
      List<String> widgetTypeValues) {
    final values = widgetTypeValues.map((e) => [e]).toList();
    return getAllByIndex(r'widgetType', values);
  }

  List<WidgetConfig?> getAllByWidgetTypeSync(List<String> widgetTypeValues) {
    final values = widgetTypeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'widgetType', values);
  }

  Future<int> deleteAllByWidgetType(List<String> widgetTypeValues) {
    final values = widgetTypeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'widgetType', values);
  }

  int deleteAllByWidgetTypeSync(List<String> widgetTypeValues) {
    final values = widgetTypeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'widgetType', values);
  }

  Future<Id> putByWidgetType(WidgetConfig object) {
    return putByIndex(r'widgetType', object);
  }

  Id putByWidgetTypeSync(WidgetConfig object, {bool saveLinks = true}) {
    return putByIndexSync(r'widgetType', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByWidgetType(List<WidgetConfig> objects) {
    return putAllByIndex(r'widgetType', objects);
  }

  List<Id> putAllByWidgetTypeSync(List<WidgetConfig> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'widgetType', objects, saveLinks: saveLinks);
  }
}

extension WidgetConfigQueryWhereSort
    on QueryBuilder<WidgetConfig, WidgetConfig, QWhere> {
  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WidgetConfigQueryWhere
    on QueryBuilder<WidgetConfig, WidgetConfig, QWhereClause> {
  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause> idBetween(
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

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause> widgetTypeEqualTo(
      String widgetType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'widgetType',
        value: [widgetType],
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterWhereClause>
      widgetTypeNotEqualTo(String widgetType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'widgetType',
              lower: [],
              upper: [widgetType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'widgetType',
              lower: [widgetType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'widgetType',
              lower: [widgetType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'widgetType',
              lower: [],
              upper: [widgetType],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WidgetConfigQueryFilter
    on QueryBuilder<WidgetConfig, WidgetConfig, QFilterCondition> {
  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition> heightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      heightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      heightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition> heightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      isVisibleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isVisible',
        value: value,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      positionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      positionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'position',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'widgetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'widgetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'widgetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'widgetType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'widgetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'widgetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'widgetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'widgetType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'widgetType',
        value: '',
      ));
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterFilterCondition>
      widgetTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'widgetType',
        value: '',
      ));
    });
  }
}

extension WidgetConfigQueryObject
    on QueryBuilder<WidgetConfig, WidgetConfig, QFilterCondition> {}

extension WidgetConfigQueryLinks
    on QueryBuilder<WidgetConfig, WidgetConfig, QFilterCondition> {}

extension WidgetConfigQuerySortBy
    on QueryBuilder<WidgetConfig, WidgetConfig, QSortBy> {
  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByIsVisible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByIsVisibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> sortByWidgetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetType', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy>
      sortByWidgetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetType', Sort.desc);
    });
  }
}

extension WidgetConfigQuerySortThenBy
    on QueryBuilder<WidgetConfig, WidgetConfig, QSortThenBy> {
  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByIsVisible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByIsVisibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVisible', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy> thenByWidgetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetType', Sort.asc);
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QAfterSortBy>
      thenByWidgetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetType', Sort.desc);
    });
  }
}

extension WidgetConfigQueryWhereDistinct
    on QueryBuilder<WidgetConfig, WidgetConfig, QDistinct> {
  QueryBuilder<WidgetConfig, WidgetConfig, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QDistinct> distinctByIsVisible() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isVisible');
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QDistinct> distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<WidgetConfig, WidgetConfig, QDistinct> distinctByWidgetType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'widgetType', caseSensitive: caseSensitive);
    });
  }
}

extension WidgetConfigQueryProperty
    on QueryBuilder<WidgetConfig, WidgetConfig, QQueryProperty> {
  QueryBuilder<WidgetConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WidgetConfig, double, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<WidgetConfig, bool, QQueryOperations> isVisibleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isVisible');
    });
  }

  QueryBuilder<WidgetConfig, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<WidgetConfig, String, QQueryOperations> widgetTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'widgetType');
    });
  }
}
