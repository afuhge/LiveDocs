package info.scce.cinco.product.documentproject.template.checks

import info.scce.cinco.product.documentproject.template.mcam.modules.checks.TemplateCheck
import info.scce.cinco.product.documentproject.template.template.Template
import java.util.List
import info.scce.cinco.product.documentproject.generator.Helper

class UniquePanelNames extends TemplateCheck{
	
	protected extension Helper = new Helper
	
	override check(Template model) {
		checkUniqueness(model, model.panels.map[name])
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
			addError(model, "The use of the panel headline '" + name + "' is not unique")
		}
	}
}