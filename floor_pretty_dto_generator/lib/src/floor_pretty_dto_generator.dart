import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_pretty_dto/floor_pretty_dto.dart';
import 'package:floor_pretty_dto_generator/src/class_element_info.dart';
import 'package:source_gen/source_gen.dart';

class PrettyDtoGenerator extends GeneratorForAnnotation<PrettyDto> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement)
      throw InvalidGenerationSourceError('The element annotated with @PrettyDto is not a class.', element: element);

    final ClassElement classElement = element as ClassElement;
    final classElementInfo = ClassElementInfo.parse(classElement);

    final resultCode = Code(_generateCode(classElementInfo));
    final library = Library((builder) => builder..body.add(resultCode));
    return library.accept(DartEmitter()).toString();
  }

  String _generateCode(ClassElementInfo classElementInfo) {
    return "${_generateDirtyDto(classElementInfo)}\n\n";
  }

  String _generateDirtyDto(ClassElementInfo classElementInfo) {
    final viewNameCode = StringBuffer();
    if (classElementInfo.annotation.viewName != null) {
      viewNameCode.write(", viewName: \"${classElementInfo.annotation.viewName}\"");
    }
    final code = StringBuffer();
    code.write("@DatabaseView(\"${classElementInfo.annotation.query}\"$viewNameCode)\n");
    code.write("class Dirty${classElementInfo.name} {\n");
    for (final field in classElementInfo.foldedFields) {
      code.write("final ${field.type} ${field.name};\n");
    }
    code.write("\n\n");
    code.write(_generateDirtyDtoConstructor(classElementInfo));
    code.write("\n\n");
    code.write(_generateMethodToPrettyDto(classElementInfo));
    code.write("}");

    return code.toString();
  }

  String _generateDirtyDtoConstructor(ClassElementInfo classElementInfo) {
    final code = StringBuffer();
    if (classElementInfo.foldedFields.isNotEmpty) {
      code.write("Dirty${classElementInfo.name}({\n");
      for (final field in classElementInfo.foldedFields) {
        code.write("this.${field.name},");
      }
      code.write("});");
    } else {
      code.write("Dirty${classElementInfo.name}();");
    }
    return code.toString();
  }

  String _generateMethodToPrettyDto(ClassElementInfo classElementInfo) {
    final code = StringBuffer();
    code.write("${classElementInfo.name} toPrettyDto() {\n");
    code.write("return ${classElementInfo.name}(");
    void writeField(FieldInfo field) {
      if (field is EntityFieldInfo) {
        code.write("${field.name}: ${field.type.name}(");
        for (final f in field.fields) {
          writeField(f);
        }
        code.write("),");
      } else {
        code.write("${field.name}: ${field.name},");
      }
    }
    for (final field in classElementInfo.fields) {
      writeField(field);
    }
    code.write(");");
    code.write("}");

    return code.toString();
  }
}
