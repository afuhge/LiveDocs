package info.scce.cinco.product.documentproject.generator.DataClassGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.Dependency
import java.util.List
import org.eclipse.emf.common.util.EList

class PanelClasses_Generator {
	
	protected extension Helper = new Helper
	
	def generate(List<Panel> panels, List<XOR> xors)'''
		import 'package:generated_webapp/abstract_classes/Panel.dart';
		import 'package:generated_webapp/panel_logs_classes.dart';
		import 'document_classes.dart';
		import 'abstract_classes/Dependency.dart';
		import 'dependency_classes.dart';
		import 'dart:html' as html;
		import 'package:collection/collection.dart';
		
		«FOR panel : panels»
			class «panel.escape» extends Panel {
				List<«panel.escape»LogEntry> logs = <«panel.escape»LogEntry>[];
				
				«IF panel.tmplPanel.dependencys.isNullOrEmpty»
				«panel.escape»(doc) : super.fromDocument(doc);
				«ELSE»
				«panel.escape»(doc) : super.fromDocument(doc){
					«generateConstructorWithDependencies(panel.tmplPanel.dependencys)»
				}
				«generateDependencyGetter(panel.tmplPanel.dependencys)»
				«ENDIF»
				
				«generateGetInput(panel)»
				«generateField(panel)»
				«generateSelect()»
				«generateInput()»
				«generateLabel()»
				«generateValue()»
				
				//--------------------Persistence-------
				@override
				get name => "«panel.tmplPanel.name.toFirstUpper»";
				
				«generateFieldVariables(panel)»
				
				«generateToJson(panel)»
				
				«generateFromJson(panel, xors)»
			}
				 
		«ENDFOR»
		
		«FOR xor : xors»
			class XOR_«xor.id.replace("_", "").replace("-","")» extends Panel {
						
				XOR_«xor.id.replace("_", "").replace("-","")»(doc) : super.fromDocument(doc);
				
				«generateGetInput(xor)»
						
				@override
				get name => "Please choose one";
				
					
				«generateToJsonXORs(xor)»
						
				«generateFromJsonXORs(xor, xors)»
			}
						 
		«ENDFOR»
	'''
	
	def generateValue()'''
	getValue(html.Element input) {
	    if(input.getAttribute("value")!= null){
	      return "'${input.getAttribute("value")}'";
	    }else {
	      return "'null'";
	    }
	  }'''
	
	def generateLabel() '''
	String getLabel(html.Element label) {
		if(label != null){
			return "<label>${label.text}</label>\n";
		}else {
			return "";
		}
	}'''
	
	def generateInput()'''
	String getInput(html.Element field) {
		var input = field.querySelector('input');
		if (input != null) {
		    return "<input type='${input.getAttribute("type")}' id='${input
		        .getAttribute("id")}' value=${getValue(input)}/>\n";
		} else {
			return "";
		}
	}
	'''
	
	def generateSelect()'''
	String getSelect(html.Element field) {
		var select = field.querySelector('select');
		if (select != null) {
			return "<input type='${select.getAttribute("type")}' id='${select
		        .getAttribute("id")}' value=${getValue(select)}/>\n";
		} else {
		 	return "";
		}
	}
						
	'''
	
	def generateField(Panel panel)'''
	String getField(html.Element panel) {
		String dom ="";
			panel.querySelectorAll('.field').map((field) {
				dom+= "<field> \n"+ getInput(field) + getSelect(field) + getLabel(field.querySelector('label'))  + "</field>";}
			).join("");
			return dom;
		}
	'''
	
	def generateGetInput(Panel panel) '''
		//------DOM Transformation-------------------------------------------
		getPanelInput(){
			var eq = const Equality().equals;
			var panels = html.document.querySelectorAll('.panel');
			var «panel.escape.toFirstLower» = null;
			panels.forEach((panel) {
				if(eq(panel.tagName, "«panel.escape.toUpperCase.replace("_","-")»")){
					«panel.escape.toFirstLower» = panel;
				}
			});
			if(«panel.escape.toFirstLower» != null){
				return	«generateInvertedCommas»${getField(«panel.escape.toFirstLower»)}«generateInvertedCommas»;
			}
		}
				
	'''
	
	def generateGetInput(XOR panel) '''
		//------DOM Transformation-------------------------------------------
		getPanelInput(){
			var eq = const Equality().equals;
			var panels = html.document.querySelectorAll('.panel');
			var «panel.escape.toFirstLower» = null;
			panels.forEach((panel) {
				if(eq(panel.tagName, "«panel.escape.toUpperCase.replace("_","-")»")){
					«panel.escape.toFirstLower» = panel;
				}
			});
			if(«panel.escape.toFirstLower» != null){
				return	"";
			}
		}
				
	'''
	
	def generateFromJsonXORs(XOR xor, List<XOR> xors) '''
	XOR_«xor.id.replace("_", "").replace("-","")».fromJson(json, Map cache) {
			id = json['id'];
			cache[id] = this;
			if(json.containsKey('next') && json['next'] != null){
				if(cache.containsKey(json['next']['id'])){
					next = cache[json['next']['id']];
				}else{
					switch(json['next']['__type']){
					«FOR panel1 : xor.rootElement.allPanels»
					case "«panel1.escape»" : next = «panel1.escape».fromJson(json['next'], cache); break;
					«ENDFOR»
					«FOR xor1 : xors»
					case "XOR_«xor.id.replace("_", "").replace("-","")»" : next = XOR_«xor.id.replace("_", "").replace("-","")».fromJson(json['next'], cache); break;
					«ENDFOR»
						}
					}
			} 	
			isSubmitted = json['isSubmitted'];
			panelOpen = json['panelOpen'];
			if(json.containsKey('submitTime') && json['submitTime'] != null) {
				submitTime = DateTime.parse(json['submitTime']);
			}
			if(json.containsKey('doc') && json['doc'] != null){
				if(cache.containsKey(json['doc']['id'])){
			    	doc = cache[json['doc']['id']];
			    }else{
			        doc = Document_«xor.rootElement.escape».fromJson(json['doc'], cache);
			    }
			}
			if(json.containsKey('dependencies') && json['dependencies'] != null) {
				dependencies = json['dependencies'] == null ? null : new List<Dependency>.from(
				json['dependencies'].map((i) {
				switch (i['__type']) {
				default : throw new Exception("exhaustive if");
				}}));
			}
		}
	'''
	
	
	
	def generateToJsonXORs(XOR xor)'''
	Map<String, dynamic> toJson(Map cache) {
			Map json = new Map<String, dynamic>();
			if (cache.containsKey(id)) {
			 	json["id"]=id;
			} else {
				cache[id] = this;
				json["id"] = id;
				json["__type"] ="XOR_«xor.id.replace("_", "").replace("-","")»";
				json["name"] = name;
				json["next"] = next == null ? null : next.toJson(cache);
				json["isSubmitted"] = isSubmitted;
				json["panelOpen"] = panelOpen;
				json["submitTime"] = submitTime?.toIso8601String();
				json["doc"] = doc.toJson(cache);
				json["dependencies"] = dependencies.map((e) => e.toJson(cache)).toList();
			}
			return json;
		}
	'''
	
	def generateToJson(Panel panel)'''
	 Map<String, dynamic> toJson(Map cache) {
		Map json = new Map<String, dynamic>();
		if (cache.containsKey(id)) {
		 	json["id"]=id;
		} else {
			cache[id] = this;
			json["id"] = id;
			json["__type"] ="«panel.escape»";
			json["name"] = name;
			json["next"] = next == null ? null : next.toJson(cache);
			json["isSubmitted"] = isSubmitted;
			json["panelOpen"] = panelOpen;
			json["submitTime"] = submitTime?.toIso8601String();
			json["doc"] = doc.toJson(cache);
			json["dependencies"] = dependencies.map((e) => e.toJson(cache)).toList();
			json["logs"] = logs.map((e) => e.toJson(cache)).toList();
			«generateFields(panel.tmplPanel.fields)»
			«generateDependencies(panel.tmplPanel.dependencys)»
		}
		return json;
	}
	'''
	
	
	def generateFromJson(Panel panel,List<XOR> xors)'''
	«panel.escape».fromJson(json, Map cache) {
		id = json['id'];
		cache[id] = this;
		if(json.containsKey('next') && json['next'] != null){
			if(cache.containsKey(json['next']['id'])){
				next = cache[json['next']['id']];
			}else{
				switch(json['next']['__type']){
				«FOR panel1 : panel.rootElement.allPanels»
				case "«panel1.escape»" : next = «panel1.escape».fromJson(json['next'], cache); break;
				«ENDFOR»
				«FOR xor : xors»
				case "XOR_«xor.id.replace("_", "").replace("-","")»" : next = XOR_«xor.id.replace("_", "").replace("-","")».fromJson(json['next'], cache); break;
				«ENDFOR»
					}
				}
		} 	
		isSubmitted = json['isSubmitted'];
		panelOpen = json['panelOpen'];
		if(json.containsKey('submitTime') && json['submitTime'] != null) {
			submitTime = DateTime.parse(json['submitTime']);
		}
		if(json.containsKey('doc') && json['doc'] != null){
			if(cache.containsKey(json['doc']['id'])){
		    	doc = cache[json['doc']['id']];
		    }else{
		        doc = Document_«panel.rootElement.escape».fromJson(json['doc'], cache);
		    }
		}
		if(json.containsKey('dependencies') && json['dependencies'] != null) {
			dependencies = json['dependencies'] == null ? null : new List<Dependency>.from(
			json['dependencies'].map((i) {
			switch (i['__type']) {
			«FOR dep : panel.tmplPanel.dependencys»
			case "«dep.dependency.escape»" : {
			if (cache.containsKey(i['id'])) {
				return cache[i['id']];
			} else {
				return «dep.dependency.escape».fromJson(i, cache);
			}
			} break;
			«ENDFOR»
			default : throw new Exception("exhaustive if");
			}}));
		}
		logs = new List<«panel.escape»LogEntry>.from(json['logs'].map((i) =>  «panel.escape»LogEntry.fromJson(i, cache)).toList());
		«generateFromJsonFields(panel.tmplPanel.fields)»
		«generateFromJsonDependencies(panel.tmplPanel.dependencys)»
	}
	'''
	
	
	def generateFromJsonDependencies(EList<Dependency> deps) '''
	«FOR dep : deps.toList»
	if(json.containsKey('_«dep.dependency.escape.toFirstLower»') && json['_«dep.dependency.escape.toFirstLower»'] != null){
		if(cache.containsKey(json['_«dep.dependency.escape.toFirstLower»']['id'])){
			_«dep.dependency.escape.toFirstLower» = cache[json['_«dep.dependency.escape.toFirstLower»']['id']];
		}else{
			_«dep.dependency.escape.toFirstLower» = «dep.dependency.escape».fromJson(json['_«dep.dependency.escape.toFirstLower»'], cache);
		}
	}
	«ENDFOR»
	'''
	
	
	
	def generateConstructorWithDependencies(EList<Dependency> list) '''
		«FOR dep : list»
		«dep.dependency.escape» new«dep.dependency.escape» = new «dep.dependency.escape»(doc);
		_«dep.dependency.escape.toFirstLower» = new«dep.dependency.escape»;
		dependencies.add(new«dep.dependency.escape»);
		«ENDFOR»
	'''
	
	def generateDependencyGetter(EList<Dependency> deps) {
		'''
		«FOR dep : deps»
		«dep.dependency.escape» get «dep.dependency.escape.toFirstLower» => _«dep.dependency.escape.toFirstLower»;
		«ENDFOR»
		'''
	}
	
	
}
