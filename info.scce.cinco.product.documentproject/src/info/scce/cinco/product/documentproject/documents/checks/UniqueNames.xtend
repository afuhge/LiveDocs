package info.scce.cinco.product.documentproject.documents.checks

import info.scce.cinco.product.documentproject.documents.mcam.modules.checks.DocumentsCheck
import java.util.List
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency

class UniqueNames extends DocumentsCheck{
	
	protected extension Helper = new Helper
	
	override check(Documents model) {
		checkUniqueness(model, model.roles.map[name])
		checkUniqueness(model, model.documents.map[(dependency as Dependency).name])
	}
	
	def checkUniqueness(Documents model, List<String> names) {
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
			addError(model, "The use of the element name '" + name + "' is not unique")
		}
	}
	
	
}