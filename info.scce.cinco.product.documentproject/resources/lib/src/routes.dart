import 'package:angular_router/angular_router.dart';

import 'routes_paths.dart';
import 'user_component/user_component.template.dart' as user_template;
import 'user_data_modal/user_data_component.template.dart' as user_data_template;
import 'dashboard/dashboard_component.template.dart' as dashboard_template;
import 'panel/panel_component.template.dart' as panel_template;
import 'docs/doc_component.template.dart' as doc_template;
export 'routes_paths.dart';

class Routes {
  static final users = RouteDefinition(
    routePath: RoutePaths.users,
    component: user_template.UserComponentNgFactory,
  );

  static final userdata = RouteDefinition(
    routePath: RoutePaths.userdata_modal,
    component: user_data_template.UserDataComponentNgFactory
  );

  static final docs = RouteDefinition(
    routePath: RoutePaths.docs,
    component: doc_template.DocComponentNgFactory,
  );


  static final dashboard = RouteDefinition(
    routePath: RoutePaths.dashboard,
    component: dashboard_template.DashboardComponentNgFactory,
  );

static final panels = RouteDefinition(
  routePath:  RoutePaths.panel,
  component:  panel_template.PanelComponentNgFactory,
);

  static final all = <RouteDefinition>[
    users, userdata, dashboard, panels, docs,
    RouteDefinition.redirect(
      path: '',
      redirectTo: RoutePaths.dashboard.toUrl(),
    ),
  ];
}