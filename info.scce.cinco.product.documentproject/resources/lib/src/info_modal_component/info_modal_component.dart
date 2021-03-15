import 'package:angular/angular.dart';
import 'package:generated_webapp/abstract_classes/Document.dart';

@Component(
  selector: 'infomodal',
  templateUrl: 'info_modal_component.html',
  directives:[coreDirectives],
)

class InfoModalComponent implements OnInit{

  @Input()
  Document doc;
  bool showModal = false;




  InfoModalComponent();

  void close(dynamic event) async {
    showModal=false;
    event.stopPropagation();
  }

  @override
  void ngOnInit() {
    if(doc.validMsg.length == 0){
      doc.mc_msg = '''No model checking status available.''';
    }
  }

}