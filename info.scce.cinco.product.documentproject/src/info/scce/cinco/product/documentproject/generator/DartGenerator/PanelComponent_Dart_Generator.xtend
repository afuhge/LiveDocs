package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List

class PanelComponent_Dart_Generator {
	protected extension Helper = new Helper
	def generate(List<Panel> panels, List<XOR> xors)'''
		import 'package:angular/angular.dart';
		import 'package:angular_forms/angular_forms.dart';
		import 'package:angular_router/angular_router.dart';
		import 'package:generated_webapp/abstract_classes/Document.dart';
		«generatePanelImports(panels)»
		«generateXORImports(xors)»
		import 'package:generated_webapp/src/panels_switch_component/panels_switch_component.dart';
		import 'package:generated_webapp/src/service/documents_service.dart';
		import '../routes.dart';
		import '../routes_paths.dart';
		
		
		@Component(
		  selector: 'my-panel',
		  templateUrl: 'panel_component.html',
		  directives: [
		    coreDirectives,
		    routerDirectives,
		    formDirectives,
		    «generateXORPanelComponentDirectives(xors)»
		    «generatePanelComponentDirectives(panels)»,
		    PanelsSwitchComponent,
		  ],
		  exports: [RoutePaths, Routes],
		)
		class PanelComponent implements OnActivate , OnDeactivate{
		  ControlGroup myPanel;
		  final Location _location;
		  DocumentService _documentService;
		  PanelComponent(this._documentService, this._location){
		  }
		  Document doc;
		
		
		  @override
		  void onActivate(RouterState previous, RouterState current) async {
		    final id = getId(current.parameters);
		    if (id != null) {
		      _documentService.notify(id);
		      doc = await (_documentService.get(id));
		    }
		  }
		
		  void back() => _location.back();
		
		  @override
		  void onDeactivate(RouterState current, RouterState next) {
		    _documentService.notify(0);
		  }
		
		}
	'''
}
