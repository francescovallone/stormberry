import 'package:build/build.dart';
import 'package:path/path.dart' as path;

import '../generators/repository_generator.dart';
import '../schema.dart';
import 'output_builder.dart';

class SchemaBuilder extends OutputBuilder {
  SchemaBuilder(BuilderOptions options, [SchemaState? schema]) : super('dart', options, schema);

  @override
  String buildTarget(BuildStep buildStep, AssetState asset) {
    return '''
      part of '${path.basename(buildStep.inputId.path)}';
      
      ${RepositoryGenerator().generateRepositories(asset)}
    ''';
  }
}
