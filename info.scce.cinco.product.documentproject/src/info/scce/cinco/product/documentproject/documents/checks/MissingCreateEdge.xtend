package info.scce.cinco.product.documentproject.documents.checks

import info.scce.cinco.product.documentproject.documents.mcam.modules.checks.DocumentsCheck
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency

class MissingCreateEdge extends DocumentsCheck{
	
	override check(Documents model) {
		var hasCreateEdge = false
		for( doc : model.documents){
			if(!doc.incomingCreateDocuments.isNullOrEmpty){
				hasCreateEdge = true
			}
		}
		if(!hasCreateEdge){
			addError(model, '''At least one Document needs an incoming Create-Edge from a role.''')
		}
		
//		for( role : model.roles){
//			if(role.outgoingCreateDocuments.isNullOrEmpty){
//				addInfo(role, '''Role '«role.name»' has no outgoing Create-Edge to a document. This role cannot create a document in the web application.''')
//			}
//		}
	}
	
}