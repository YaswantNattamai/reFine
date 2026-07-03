// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutSetProgressCollection on Isar {
  IsarCollection<WorkoutSetProgress> get workoutSetProgress =>
      this.collection();
}

const WorkoutSetProgressSchema = CollectionSchema(
  name: r'WorkoutSetProgress',
  id: -2735632111371897744,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'setsCompleted': PropertySchema(
      id: 1,
      name: r'setsCompleted',
      type: IsarType.boolList,
    ),
    r'workoutId': PropertySchema(
      id: 2,
      name: r'workoutId',
      type: IsarType.long,
    )
  },
  estimateSize: _workoutSetProgressEstimateSize,
  serialize: _workoutSetProgressSerialize,
  deserialize: _workoutSetProgressDeserialize,
  deserializeProp: _workoutSetProgressDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _workoutSetProgressGetId,
  getLinks: _workoutSetProgressGetLinks,
  attach: _workoutSetProgressAttach,
  version: '3.1.0+1',
);

int _workoutSetProgressEstimateSize(
  WorkoutSetProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.setsCompleted.length;
  return bytesCount;
}

void _workoutSetProgressSerialize(
  WorkoutSetProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeBoolList(offsets[1], object.setsCompleted);
  writer.writeLong(offsets[2], object.workoutId);
}

WorkoutSetProgress _workoutSetProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutSetProgress();
  object.date = reader.readDateTime(offsets[0]);
  object.id = id;
  object.setsCompleted = reader.readBoolList(offsets[1]) ?? [];
  object.workoutId = reader.readLong(offsets[2]);
  return object;
}

P _workoutSetProgressDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBoolList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutSetProgressGetId(WorkoutSetProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutSetProgressGetLinks(
    WorkoutSetProgress object) {
  return [];
}

void _workoutSetProgressAttach(
    IsarCollection<dynamic> col, Id id, WorkoutSetProgress object) {
  object.id = id;
}

extension WorkoutSetProgressQueryWhereSort
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QWhere> {
  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkoutSetProgressQueryWhere
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QWhereClause> {
  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterWhereClause>
      idBetween(
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

extension WorkoutSetProgressQueryFilter
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QFilterCondition> {
  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedElementEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'setsCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setsCompleted',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setsCompleted',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setsCompleted',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setsCompleted',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setsCompleted',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      setsCompletedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setsCompleted',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      workoutIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workoutId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      workoutIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workoutId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      workoutIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workoutId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterFilterCondition>
      workoutIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workoutId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutSetProgressQueryObject
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QFilterCondition> {}

extension WorkoutSetProgressQueryLinks
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QFilterCondition> {}

extension WorkoutSetProgressQuerySortBy
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QSortBy> {
  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      sortByWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      sortByWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.desc);
    });
  }
}

extension WorkoutSetProgressQuerySortThenBy
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QSortThenBy> {
  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      thenByWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QAfterSortBy>
      thenByWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.desc);
    });
  }
}

extension WorkoutSetProgressQueryWhereDistinct
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QDistinct> {
  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QDistinct>
      distinctBySetsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'setsCompleted');
    });
  }

  QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QDistinct>
      distinctByWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutId');
    });
  }
}

extension WorkoutSetProgressQueryProperty
    on QueryBuilder<WorkoutSetProgress, WorkoutSetProgress, QQueryProperty> {
  QueryBuilder<WorkoutSetProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutSetProgress, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<WorkoutSetProgress, List<bool>, QQueryOperations>
      setsCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'setsCompleted');
    });
  }

  QueryBuilder<WorkoutSetProgress, int, QQueryOperations> workoutIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutId');
    });
  }
}
