import 'package:angular_router/angular_router.dart';
import 'routes_paths_parent.dart' as parent;

const idParam ='id';

class RoutePaths {
  static final users = RoutePath(path: 'users', parent: parent.RoutePathsParent.pagecontent);
  static final dashboard = RoutePath(path: 'dashboard', parent: parent.RoutePathsParent.pagecontent);
  static final docs = RoutePath(path: 'docs', parent: parent.RoutePathsParent.pagecontent);
  static final panel = RoutePath(path: 'doc/:$idParam', parent: parent.RoutePathsParent.pagecontent);
  static final userdata_modal = RoutePath(path: 'userdata_modal', parent: parent.RoutePathsParent.pagecontent);

}

int getId(Map<String, String> parameters) {
  final id = parameters[idParam];
  return id == null ? null : int.tryParse(id);
}