import 'dart:async';
import 'package:angular/angular.dart';
import 'package:generated_webapp/src/service/notification_service.dart';
import 'package:generated_webapp/src/service/users_service.dart';
import 'package:generated_webapp/src/service/documents_service.dart';
import 'package:generated_webapp/abstract_classes/Document.dart';
import '../user.dart';

@Component(
  selector: 'closedoc',
  templateUrl: 'close_document_modal_component.html',
  directives:[coreDirectives],
)

class CloseDocumentModalComponent implements OnInit{
  @Input()
  String msg;

  @Input()
  bool valid;

  @Input()
  Document doc;

  final DocumentService _documentService;
  bool clickYes = false;
  bool showModal = false;
  bool deleted = false;




  CloseDocumentModalComponent(this._documentService);

  void close(dynamic event) async {
    deleted = true;
    doc.isOpen = false;
    new Timer(new Duration(seconds: 3), () {
      deleted = false;
    });
    showModal=false;
    event.stopPropagation();
    _documentService.persist();
  }

  @override
  void ngOnInit() {
    if(msg.length == 0){
      msg = '''Nothing is submitted.''';
    }
  }





}