import 'package:angular/angular.dart';
import 'package:generated_webapp/abstract_classes/Panel.dart';
import 'package:generated_webapp/src/doctreepanel_component/treepanel_component.dart';


@Component(
  selector: 'doctree-switch',
  templateUrl: 'doctree_switch_component.html',
  directives : [ coreDirectives, DocTreeSwitchComponent, TreePanelComponent],

)

class DocTreeSwitchComponent {
  @Input()
  Panel panel;

}