package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.Panel

class PanelLogComponents_Dart_Generator {
	
	protected extension Helper = new Helper
	def generate (info.scce.cinco.product.documentproject.dependency.dependency.Panel panel)'''
		import 'package:angular/angular.dart';
		import 'package:angular_forms/angular_forms.dart';
		import 'package:generated_webapp/panel_logs_classes.dart';
		
		@Component(
		  selector: '«panel.escape.toFirstLower.replace("_","-")»log',
		  templateUrl: 'panelLog_modal_component.html',
		  directives: [coreDirectives, formDirectives],
		  pipes: [commonPipes],
		)
		class «panel.escape»LogModalComponent {
		  bool showModal = false;
		
		  @Input()
		  List<«panel.escape»LogEntry> logs;
		  
		}
		
	'''
}
