import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/src/route_parents.dart';
import 'package:generated_webapp/src/routes_paths_parent.dart';
import 'package:generated_webapp/src/service/users_service.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: [coreDirectives, routerDirectives],
  exports: [RoutePathsParent, RoutesParent],
  providers: [ClassProvider(UserService)]
)


class AppComponent{}