package info.scce.cinco.product.documentproject.documents.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.documents.documents.Document

class OpenModel extends CincoCustomAction<Document> {
	
	override execute(Document doc) {
		doc.dependency.openEditor
	}
	
}