import 'package:build/build.dart';
import 'package:floor_pretty_dto_generator/src/floor_pretty_dto_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder prettyDto(BuilderOptions options) => SharedPartBuilder([PrettyDtoGenerator()], 'floor_pretty_dto');
