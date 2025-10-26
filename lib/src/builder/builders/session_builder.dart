import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../schema.dart';

class SessionBuilder extends Builder {

  SessionBuilder();

  @override
  Future<void> build(BuildStep buildStep) async {
    SchemaState state = await buildStep.fetchResource(schemaResource);
    final List<({String path, AssetState asset})> assets = [];
    await buildStep.findAssets(Glob('lib/**.dart')).asyncMap((id) async {
      var asset = state.getForAsset(id);
      if (asset != null && asset.tables.isNotEmpty) {
        assets.add((path: id.path, asset: asset));
      }
    }).toList();
    final StringBuffer repositoriesExtension = StringBuffer();
    if (assets.isNotEmpty) {
      repositoriesExtension.writeln('import \'package:stormberry/stormberry.dart\' as sb;');
      for (final element in assets) {
        final importPath = element.path.replaceFirst('lib/', '');
        repositoriesExtension.writeln('import \'$importPath\';');
      }
      repositoriesExtension.writeln('');
      repositoriesExtension.writeln('extension AllRepositories on sb.Session {');
      repositoriesExtension.writeln('  Map<Type, sb.ModelRepository> get allRepositories => {');
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
        '${repositoriesExtension.toString()}';

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/session.schema.dart'),
      output,
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['session.schema.dart'],
  };

}