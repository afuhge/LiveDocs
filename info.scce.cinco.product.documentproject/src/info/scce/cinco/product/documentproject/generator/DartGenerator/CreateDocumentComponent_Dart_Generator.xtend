package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.documents.documents.Role

class CreateDocumentComponent_Dart_Generator {
	protected extension Helper = new Helper
	def generate(Documents doc)'''
	import 'package:angular/angular.dart';
	import 'package:angular_forms/angular_forms.dart';
	import 'package:generated_webapp/document_classes.dart';
	import 'package:generated_webapp/src/service/documents_service.dart';
	import 'package:generated_webapp/src/service/notification_service.dart';
	import 'package:intl/intl.dart';
	import 'package:generated_webapp/src/service/users_service.dart';
	
	@Component(
	  selector : 'createdoc',
	  templateUrl: 'create_document_component.html',
	  directives : [coreDirectives, formDirectives],
	)
	class CreateDocumentComponent implements OnInit{
	  bool showModal = false;
	  ControlGroup createDoc;
	  bool submitted = false;
	  final NotificationService _nService;
	 final DocumentService _documentService;
	 final UserService _userService;
	
	  CreateDocumentComponent(this._nService, this._documentService, this._userService){}
	  get docTypes =>  _documentService.doctypes;
	
	
	  @override
	  void ngOnInit() {
	    submitted = false;
	    createDoc = FormBuilder.controlGroup({
	      'docName': ['', Validators.compose([Validators.required, Validators.minLength(3)])],
	      'type' : [ docTypes.first, Validators.compose([Validators.required])]
	    });
	  }
	  
	  bool isEnabled(){
	  «FOR canWrite : doc.allCanWriteElements AFTER 'else { return false; }'»
	  if(_userService.currentUser.role >= "«canWrite.name.toFirstUpper»"){
	  	return true;
	  }
	  «ENDFOR»
	      
	   }
	
	  void close(){
	    showModal=false;
	    createDoc.reset();
	    createDoc.controls['type'].updateValue(docTypes.first);
	  }
	
	  void submit(dynamic event, ControlGroup createDoc) async{
	    submitted = true;
	    createDocument(createDoc);
	    Notification notification = Notification("Success!", "Document: " + createDoc.controls['docName'].value + " created.");
	    _nService.notify(notification);
	    showModal=false;
	    createDoc.reset();
	    createDoc.controls['type'].updateValue(docTypes.first);
	    event.stopPropagation();
	  }
	
	  void createDocument(ControlGroup createDoc) {
	    var newDoc;
	    «generateDocumentConstructors(doc)»
	     newDoc.creationDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
	    newDoc.isOpen = true;
	    newDoc.creator = _userService.currentUser;
	    newDoc.fileName = createDoc.controls['docName'].value;
	    _documentService.addDocument(newDoc);
	  }
	
	
	}
	
	
	'''
	
	def Iterable<Role> allCanWriteElements(Documents documents){
		return documents.roles.filter[!outgoingCreateDocuments.isNullOrEmpty];
	}
	
	def generateDocumentConstructors(Documents docs) '''
		«FOR doc : docs.documents»
		if(createDoc.controls['type'].value == "«(doc.dependency as Dependency).name.toFirstUpper»"){
			newDoc = «doc.escape»();
		}
		«ENDFOR»
		'''
	
}