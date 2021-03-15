package info.scce.cinco.product.documentproject.generator.DataClassGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.Field
import java.util.List
import org.eclipse.emf.common.util.EList

class PanelLogsClasses_Generator {
	
	protected extension Helper = new Helper;
	
	def generate(List<Panel> panels)'''
		import 'package:generated_webapp/abstract_classes/LogEntry.dart';
		import 'package:generated_webapp/src/user.dart';
		import 'dependency_classes.dart';
		
		«FOR panel : panels»
			class «panel.escape»LogEntry extends LogEntry {
				«generateFieldVariables(panel)»
				
				«panel.escape»LogEntry () : super(){}
				
				«generateToJson(panel)»
				
				«generateFromJson(panel)»
			}
			
		«ENDFOR»
	'''
	
	def generateFieldVariables(Panel panel)'''
	«FOR field : panel.tmplPanel.fields»
	«IF field instanceof DateField»
	«field.type» «field.escape» = DateTime.now();
	«ENDIF»
	«IF !(field instanceof DateField) && !(field instanceof ChoiceField)»
	«field.type» «field.escape»;
	«ENDIF»
	«IF field instanceof ChoiceField»
	«field.type» «field.escape» = "";
	«ENDIF»
	«ENDFOR»
					 
	«FOR dep : panel.tmplPanel.dependencys»
	«(dep.dependency as Dependency).escape» «(dep.dependency as Dependency).escape.toFirstLower»;
	«ENDFOR»
	'''
	
	def generateToJson(Panel panel)'''
	Map<String, dynamic> toJson(Map cache) => {
		"user": user?.toJson(cache),
		"date" : date?.toIso8601String(),
		"content" : content,
		«generateToJsonFields(panel.tmplPanel.fields)»
		«generateDependenciesJson(panel.tmplPanel.dependencys)»
	};
	'''
	
	def generateFromJson(Panel panel)'''
	«panel.escape»LogEntry.fromJson(json, Map cache) {
		if(json.containsKey('user') && json['user'] != null){
			if(cache.containsKey(json['user']['id'])){
				user = cache[json['user']['id']];
			}else{
				user = json['user'] == null ? null : User.fromJson(json['user'],cache);
			}
		}
		date = DateTime.parse(json['date']);
		content = new Map<String, String>.from(json['content']);
		«generateFromJsonFields(panel.tmplPanel.fields)»
		«generateFromJsonDependencies(panel.tmplPanel.dependencys)»
	}
	'''
	
	def generateToJsonFields(EList<Field> fields) '''
	«FOR field : fields.toList»
	"«field.escape»" : «IF field instanceof DateField»«field.escape»?.toIso8601String()«ELSE»«field.escape»«ENDIF»,
	«ENDFOR»
	'''
	
	def generateFromJsonDependencies(EList<info.scce.cinco.product.documentproject.template.template.Dependency> deps)'''
	«FOR dep : deps.toList»
	if(json.containsKey('«(dep.dependency as Dependency).escape.toFirstLower»') && json['«(dep.dependency as Dependency).escape.toFirstLower»'] != null){
		if(cache.containsKey(json['«(dep.dependency as Dependency).escape.toFirstLower»'])){
			«(dep.dependency as Dependency).escape.toFirstLower» = cache[json['«(dep.dependency as Dependency).escape.toFirstLower»']['id']];
		}else{
			«(dep.dependency as Dependency).escape.toFirstLower» = «(dep.dependency as Dependency).escape».fromJson(json['«(dep.dependency as Dependency).escape.toFirstLower»'], cache);
		}
	}
	
	«ENDFOR»
	'''
	
	
	
	def generateDependenciesJson(EList<info.scce.cinco.product.documentproject.template.template.Dependency> deps)'''
	«FOR dep : deps.toList SEPARATOR ","»
	"«dep.dependency.escape.toFirstLower»" : «dep.dependency.escape.toFirstLower» == null ? null : «dep.dependency.escape.toFirstLower».toJson(cache)
	«ENDFOR»
	'''
}
