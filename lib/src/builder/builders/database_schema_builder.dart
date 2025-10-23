import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../schema.dart';

class DatabaseSchemaBuilder implements Builder {
  DatabaseSchemaBuilder();

  @override
  Future<void> build(BuildStep buildStep) async {
    var allSchemas =
        await buildStep
            .findAssets(Glob('lib/**.schema.json'))
            .asyncMap((id) => buildStep.readAsString(id))
            .map((c) => jsonDecode(c))
            .toList();
  
    SchemaState state = await buildStep.fetchResource(schemaResource);
    final List<({String path, AssetState asset})> assets = [];
    await buildStep.findAssets(Glob('lib/**.dart')).asyncMap((id) async {
      var asset = state.getForAsset(id);
      if (asset != null && asset.tables.isNotEmpty) {
        assets.add((path: id.path, asset: asset));
      }
    }).toList();
    var fullSchema = <String, dynamic>{};
    for (var schema in allSchemas) {
      fullSchema.addAll(schema as Map<String, dynamic>);
    }
    final StringBuffer repositoriesExtension = StringBuffer();
    if (assets.isNotEmpty) {
      repositoriesExtension.writeln('import \'package:stormberry/stormberry.dart\';');
      repositoriesExtension.writeln('import \'dart:core\' as core;');
      for (final element in assets) {
        final importPath = element.path.replaceFirst('lib/', '');
        repositoriesExtension.writeln('import \'$importPath\';');
      }
      repositoriesExtension.writeln('');
      repositoriesExtension.writeln('extension AllRepositories on Session {');
      repositoriesExtension.writeln('  core.Map<core.Type, ModelRepository> get allRepositories => {');
      for (var element in assets) {
        for (var table in element.asset.tables.values) {
          repositoriesExtension.writeln(
              '    ${table.element.name}Repository: ${table.repoName},');
        }
      }
      repositoriesExtension.writeln('  };');
      repositoriesExtension.writeln('}\n');
    }

    final output =
        '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n'
        '// ignore_for_file: type=lint\n'
        '// dart format off\n\n'
        'import \'package:stormberry/migrate.dart\';\n\n'
        '${repositoriesExtension.toString()}'
        'final DatabaseSchema schema = DatabaseSchema.fromMap(${const JsonEncoder.withIndent('  ').convert(fullSchema)});\n';

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/database.schema.dart'),
      output,
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['database.schema.dart'],
  };
}
