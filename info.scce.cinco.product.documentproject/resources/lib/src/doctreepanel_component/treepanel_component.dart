import 'package:angular/angular.dart';
import 'package:generated_webapp/abstract_classes/Panel.dart';
import 'package:generated_webapp/src/doctree_switch_component/doctree_switch_component.dart';
import 'dart:html' as html;

@Component(
  selector: 'tree-panel',
  templateUrl: 'treepanel_component.html',
  directives : [coreDirectives, DocTreeSwitchComponent]
)

class TreePanelComponent{
  @Input()
  Panel panel;


  void jumpToPanel(dynamic event){
    event.preventDefault();
    html.querySelector("#panel${panel.id}").scrollIntoView(html.ScrollAlignment.CENTER);
  }
}