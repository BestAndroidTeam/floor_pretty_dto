import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:floor_pretty_dto_generator/src/annotation_utils.dart';

class ClassElementInfo {
  final ClassElement clazz;
  final String name;
  final String query;
  final List<FieldInfo> fields;
  final ConstructorElement primaryConstructor;

  final List<FieldInfo> foldedFields;

  ClassElementInfo._(this.clazz, this.name, this.query, this.fields, this.primaryConstructor)
      : this.foldedFields = _getFoldedFields(name, fields);

  static Iterable<FieldElement> getDataFields(ClassElement clazz) {
    return clazz.fields.where((e) => !e.isStatic && !e.isSynthetic);
  }

  static ClassElementInfo parse(ClassElement clazz) {
    final name = clazz.name;
    FieldInfo getFieldInfo(FieldElement fieldElement) {
      if (fieldElement.type.element is ClassElement) {
        final fieldTypeClassElement = fieldElement.type.element as ClassElement;
        if (AnnotationUtils.hasAnnotation(fieldTypeClassElement, Entity)) {
          return EntityFieldInfo(
            name: fieldElement.name,
            type: fieldElement.type,
            fields: getDataFields(fieldTypeClassElement).map((e) => getFieldInfo(e)).toList(),
          );
        }
      }
      return FieldInfo(name: fieldElement.name, type: fieldElement.type);
    }

    final prettyDtoAnnotation = AnnotationUtils.loadPrettyDtoAnnotation(clazz);
    final fields = getDataFields(clazz).map((e) => getFieldInfo(e)).toList();
    final primaryConstructor = _getPrimaryConstructor(clazz);
    return ClassElementInfo._(clazz, name, prettyDtoAnnotation.query, fields, primaryConstructor);
  }

  String get constructorCallConstString =>
      primaryConstructor.parameters.isEmpty && primaryConstructor.isConst ? "const " : "";

  String get constructorCallNameString => primaryConstructor.name != "" ? ".${primaryConstructor.name}" : "";

  @override
  String toString() => "{clazz=$clazz, name=$name, fields=$fields, primaryConstructor=$primaryConstructor}";

  static ConstructorElement _getPrimaryConstructor(ClassElement classElement) {
    ConstructorElement constructor = null;
    /*classElement.constructors
        .firstWhere((e) => AnnotationUtils.hasAnnotation(e, PrimaryConstructor), orElse: () => null);*/
    if (constructor == null) {
      if (classElement.constructors.length == 1) {
        constructor = classElement.constructors[0];
      } else {
        throw Exception("Couldn't determine primary constructor for class ${classElement.name}.");
      }
    }
    return constructor;
  }

  static List<FieldInfo> _getFoldedFields(String className, List<FieldInfo> rootFields) {
    // Verify that field names are unique
    final Map<String, String> fieldNameBySource = Map();
    void fillFieldNameBySource(String sourcePath, FieldInfo field) {
      final actualPath = (sourcePath == "") ? field.name : "$sourcePath.${field.name}";
      if (field is EntityFieldInfo) {
        for (final it in field.fields) fillFieldNameBySource(actualPath, it);
      } else {
        if (fieldNameBySource.containsKey(field.name)) {
          throw Exception("Duplicate field name \"${field.name}\" (${fieldNameBySource[field.name]}, in $actualPath)");
        } else {
          fieldNameBySource[field.name] = actualPath;
        }
      }
    }
    for (final field in rootFields) {
      fillFieldNameBySource(className, field);
    }

    // Get folded fields
    void fillFieldAcc(List<FieldInfo> acc, FieldInfo field) {
      if (field is EntityFieldInfo) {
        for (final it in field.fields) fillFieldAcc(acc, it);
      } else {
        acc.add(field);
      }
    }

    return rootFields.fold(List<FieldInfo>(), (List<FieldInfo> acc, it) {
      fillFieldAcc(acc, it);
      return acc;
    }).toList();
  }
}

class FieldInfo {
  final String name;
  final DartType type;

  FieldInfo({this.name, this.type});

  @override
  String toString() => "{name=$name, type=$type}";
}

class EntityFieldInfo extends FieldInfo {
  final List<FieldInfo> fields;

  EntityFieldInfo({String name, DartType type, this.fields}) : super(name: name, type: type);

  @override
  String toString() => "{name=$name, type=$type, fields=$fields}";
}
