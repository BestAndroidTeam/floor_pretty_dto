import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class AnnotationUtils {
  static TypeChecker _typeChecker(final Type type) => TypeChecker.fromRuntime(type);

  static bool hasAnnotation(Element element, final Type annotationType) {
    return _typeChecker(annotationType).hasAnnotationOfExact(element);
  }
}
