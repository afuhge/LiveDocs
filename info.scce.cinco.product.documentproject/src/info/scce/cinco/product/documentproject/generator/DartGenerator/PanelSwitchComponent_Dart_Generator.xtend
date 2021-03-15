package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List

class PanelSwitchComponent_Dart_Generator {
	
	protected extension Helper = new Helper
	
	def generate(List<Panel> panels, List<XOR> xors)'''
		//this class includes all panelX components as directives
		import 'package:angular/angular.dart';
		import 'package:generated_webapp/abstract_classes/Panel.dart';
		import 'package:generated_webapp/abstract_classes/Dependency.dart';
		«generatePanelImports(panels)»
		«generateXORImports(xors)»
		import '../../panel_classes.dart';
		
		@Component(
		  selector:'panels-switch',
		  templateUrl: 'panels_switch_component.html',
		  directives :[coreDirectives,PanelsSwitchComponent, «generatePanelComponentDirectives(panels)», «generateXORPanelComponentDirectives(xors)»]
		)
		
		class PanelsSwitchComponent{
		  @Input()
		  Panel panel;
		
		  @Input()
		  Dependency dep;
		  
		  «generateInstanceofPanels(panels, xors)»
		
		}
		
	'''
	
	def generateInstanceofPanels(List<Panel> panels, List<XOR> xors)'''
		«FOR panel: panels»
			bool get instanceOf«panel.escape» => panel is «panel.escape»;
		«ENDFOR»
		«FOR xor : xors»
		bool get instanceOfXOR_«xor.id.replace("_", "").replace("-","")» => panel is XOR_«xor.id.replace("_", "").replace("-","")»;
		«ENDFOR»
	'''
}
