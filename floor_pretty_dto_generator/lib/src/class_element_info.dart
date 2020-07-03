import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:floor_pretty_dto/floor_pretty_dto.dart';
import 'package:floor_pretty_dto_generator/src/annotation_utils.dart';
import 'package:source_gen/source_gen.dart';

class ClassElementInfo {
  final ClassElement clazz;
  final String name;
  final PrettyDto annotation;
  final List<FieldInfo> fields;
  final ConstructorElement primaryConstructor;

  final List<FieldInfo> foldedFields;

  ClassElementInfo._(this.clazz, this.name, this.annotation, this.fields, this.primaryConstructor)
      : this.foldedFields = _getFoldedFields(clazz, name, fields);

  static ClassElementInfo parse(ClassElement clazz) {
    final name = clazz.name;
    FieldInfo getFieldInfo(FieldElement fieldElement) {
      if (fieldElement.type.element is ClassElement) {
        final fieldTypeClassElement = fieldElement.type.element as ClassElement;
        if (AnnotationUtils.hasAnnotation(fieldTypeClassElement, Entity)) {
          return EntityFieldInfo(
            name: fieldElement.name,
            type: fieldElement.type,
            fields: fieldTypeClassElement.fields.map((e) => getFieldInfo(e)).toList(),
          );
        }
      }
      return FieldInfo(name: fieldElement.name, type: fieldElement.type);
    }

    final prettyDtoAnnotation = AnnotationUtils.loadPrettyDtoAnnotation(clazz);
    final fields = clazz.fields.where((e) => !e.isStatic && !e.isSynthetic).map((e) {
      return getFieldInfo(e);
    }).toList();
    final primaryConstructor = _getPrimaryConstructor(clazz);
    return ClassElementInfo._(clazz, name, prettyDtoAnnotation, fields, primaryConstructor);
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
        throw InvalidGenerationSourceError("Couldn't determine primary constructor for class ${classElement.name}.",
            element: classElement);
      }
    }
    return constructor;
  }

  static List<FieldInfo> _getFoldedFields(ClassElement classElement, String className, List<FieldInfo> rootFields) {
    // Verify that field names are unique
    final Map<String, FieldSourceAndType> fieldNameBySource = Map();
    void fillFieldNameBySource(String sourcePath, FieldInfo field) {
      final currentPath = (sourcePath == "") ? field.name : "$sourcePath.${field.name}";
      if (field is EntityFieldInfo) {
        for (final it in field.fields) fillFieldNameBySource(currentPath, it);
      } else {
        if (fieldNameBySource.containsKey(field.name)) {
          final lastField = fieldNameBySource[field.name];
          if (lastField.type != field.type) {
            throw InvalidGenerationSourceError("Duplicate field name \"${field.name}\" (is ${lastField.type} in ${lastField.source}, is ${field.type} in $currentPath)",
                element: classElement);
          }
        } else {
          fieldNameBySource[field.name] = FieldSourceAndType(source: currentPath, type: field.type);
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
      } else if (acc.firstWhere((e) => e.name == field.name, orElse: () => null) == null) {
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
}

class FieldSourceAndType {
  final String source;
  final DartType type;

  FieldSourceAndType({this.source, this.type});
}

class EntityFieldInfo extends FieldInfo {
  final List<FieldInfo> fields;

  EntityFieldInfo({String name, DartType type, this.fields}) : super(name: name, type: type);

  @override
  String toString() => "{name=$name, type=$type, fields=$fields}";
}
