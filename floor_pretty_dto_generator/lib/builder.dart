import 'package:build/build.dart';
import 'package:floor_pretty_dto_generator/src/floor_pretty_dto_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder dataClass(BuilderOptions options) => SharedPartBuilder([DataClassGenerator()], 'floor_pretty_dto');
