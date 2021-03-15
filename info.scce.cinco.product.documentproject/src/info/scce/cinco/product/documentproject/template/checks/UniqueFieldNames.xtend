package info.scce.cinco.product.documentproject.template.checks

import info.scce.cinco.product.documentproject.template.mcam.modules.checks.TemplateCheck
import info.scce.cinco.product.documentproject.template.template.Template
import java.util.List

class UniqueFieldNames extends TemplateCheck{
	
	override check(Template model) {
		for (panel: model.panels){
			checkUniqueness(model, panel.fields.map[label])
		}
	}
	
	
	def checkUniqueness(Template model, List<String> names) {
		var notUnique = false;
		var name = ""
		for(var i=0; i < names.size-1; i++){
			for(var j = i+1; j < names.size; j++){
				if(names.get(j).equals(names.get(i))){
					notUnique = true
					name = names.get(j)
				}
			}
		}
		if(notUnique){
			addError(model, "The use of the field label '" + name + "' is not unique")
		}
	}
	
}