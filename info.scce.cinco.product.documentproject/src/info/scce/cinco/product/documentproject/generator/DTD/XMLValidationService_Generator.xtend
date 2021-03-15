package info.scce.cinco.product.documentproject.generator.DTD

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.documents.documents.Document

class XMLValidationService_Generator {
	static extension Helper = new Helper()
	def generate(Documents docs)'''
	import 'package:generated_webapp/src/service/notification_service.dart';
	import 'package:http/http.dart' as http;
	import 'dart:convert';
	import 'documents_service.dart';
	import '../../document_classes.dart';
	
	class XMLValidationService{
		
		«FOR doc : docs.documents »
		////String variables for XML Validation for «doc.escape»
		String «doc.escape.toFirstLower»_DTD = "";
		String «doc.escape.toFirstLower»_transformedDOM = "";
		String «doc.escape.toFirstLower»_XMLString = "";
		
		«ENDFOR»
		final DocumentService _documentService;
		final NotificationService _notificationService;
		
		XMLValidationService(this._notificationService,  this._documentService){
			«FOR doc : docs.documents »
			//set dtd variables for XML Validation for «doc.escape»
			«doc.escape.toFirstLower»_DTD = «generateInvertedCommas»«getDTD(doc)»«generateInvertedCommas»;
					
			«ENDFOR»
		}
			«FOR doc : docs.documents»
			//Set XMLString  DTD + transformed DOM for «doc.escape»
			validateXML_«doc.escape»(«doc.escape» doc) async {
		 	«doc.escape.toFirstLower»_XMLString = «doc.escape.toFirstLower»_DTD + «doc.escape.toFirstLower»_transformedDOM;
		 		print("xmlstring:" + «doc.escape.toFirstLower»_XMLString);
				var url = 'http://localhost:8000/xmlvalidation';
				var response = await http.post(url, body: «doc.escape.toFirstLower»_XMLString);
				var body = response.body;
				var parsedJson = json.decode(body);
				doc.valid = parsedJson['valid'];
				doc.validMsg = parsedJson['message'];
				_documentService.persist();
				if(doc.valid){
					Notification notification = Notification("Document status:", doc.validMsg);
					_notificationService.notify(notification);
				}
			}
			
		 	«ENDFOR»		
	}
	'''
	
	def getDTD(Document doc){
		val CharSequence generateXMLDTD= new XMLDTDFile_Generator().generate(doc)
		return generateXMLDTD
	}
}