import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/src/routes_paths_parent.dart';

import '../pagecontent_component.template.dart' as page_template;
import '../login_component.template.dart' as login_template;

export 'routes_paths.dart';



class RoutesParent {
  static final pagecontent = RouteDefinition(
    routePath: RoutePathsParent.pagecontent,
    component: page_template.PageContentComponentNgFactory,

  );

  static final login = RouteDefinition(
    routePath: RoutePathsParent.login,
    component: login_template.LoginComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    login,
    pagecontent,
    RouteDefinition.redirect(
      path: '',
      redirectTo: RoutePathsParent.login.toUrl(),
    ),
  ];
}