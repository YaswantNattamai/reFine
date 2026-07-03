// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motivation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMotivationCollection on Isar {
  IsarCollection<Motivation> get motivations => this.collection();
}

const MotivationSchema = CollectionSchema(
  name: r'Motivation',
  id: 5089873237688948574,
  properties: {
    r'quote': PropertySchema(
      id: 0,
      name: r'quote',
      type: IsarType.string,
    )
  },
  estimateSize: _motivationEstimateSize,
  serialize: _motivationSerialize,
  deserialize: _motivationDeserialize,
  deserializeProp: _motivationDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _motivationGetId,
  getLinks: _motivationGetLinks,
  attach: _motivationAttach,
  version: '3.1.0+1',
);

int _motivationEstimateSize(
  Motivation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.quote.length * 3;
  return bytesCount;
}

void _motivationSerialize(
  Motivation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.quote);
}

Motivation _motivationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Motivation();
  object.id = id;
  object.quote = reader.readString(offsets[0]);
  return object;
}

P _motivationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _motivationGetId(Motivation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _motivationGetLinks(Motivation object) {
  return [];
}

void _motivationAttach(IsarCollection<dynamic> col, Id id, Motivation object) {
  object.id = id;
}

extension MotivationQueryWhereSort
    on QueryBuilder<Motivation, Motivation, QWhere> {
  QueryBuilder<Motivation, Motivation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MotivationQueryWhere
    on QueryBuilder<Motivation, Motivation, QWhereClause> {
  QueryBuilder<Motivation, Motivation, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Motivation, Motivation, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterWhereClause> idBetween(
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

extension MotivationQueryFilter
    on QueryBuilder<Motivation, Motivation, QFilterCondition> {
  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition> quoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quote',
        value: '',
      ));
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterFilterCondition>
      quoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quote',
        value: '',
      ));
    });
  }
}

extension MotivationQueryObject
    on QueryBuilder<Motivation, Motivation, QFilterCondition> {}

extension MotivationQueryLinks
    on QueryBuilder<Motivation, Motivation, QFilterCondition> {}

extension MotivationQuerySortBy
    on QueryBuilder<Motivation, Motivation, QSortBy> {
  QueryBuilder<Motivation, Motivation, QAfterSortBy> sortByQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.asc);
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterSortBy> sortByQuoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.desc);
    });
  }
}

extension MotivationQuerySortThenBy
    on QueryBuilder<Motivation, Motivation, QSortThenBy> {
  QueryBuilder<Motivation, Motivation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterSortBy> thenByQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.asc);
    });
  }

  QueryBuilder<Motivation, Motivation, QAfterSortBy> thenByQuoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.desc);
    });
  }
}

extension MotivationQueryWhereDistinct
    on QueryBuilder<Motivation, Motivation, QDistinct> {
  QueryBuilder<Motivation, Motivation, QDistinct> distinctByQuote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quote', caseSensitive: caseSensitive);
    });
  }
}

extension MotivationQueryProperty
    on QueryBuilder<Motivation, Motivation, QQueryProperty> {
  QueryBuilder<Motivation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Motivation, String, QQueryOperations> quoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quote');
    });
  }
}
