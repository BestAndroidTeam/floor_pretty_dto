import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_pretty_dto/floor_pretty_dto.dart';
import 'package:source_gen/source_gen.dart';

class AnnotationUtils {
  static TypeChecker _typeChecker(final Type type) => TypeChecker.fromRuntime(type);

  static bool hasAnnotation(Element element, final Type annotationType) {
    return _typeChecker(annotationType).hasAnnotationOfExact(element);
  }

  static DartObject getAnnotation(Element element, final Type type) {
    try {
      return _typeChecker(type).firstAnnotationOfExact(element);
    } catch (e) {
      throw Exception("Couldn't get $type annotation on $element ($e)");
    }
  }

  static PrettyDto loadPrettyDtoAnnotation(Element element) {
    final annotation = getAnnotation(element, PrettyDto);
    return PrettyDto(annotation?.getField("query")?.toStringValue(),
        viewName: annotation?.getField("viewName")?.toStringValue());
  }
}
