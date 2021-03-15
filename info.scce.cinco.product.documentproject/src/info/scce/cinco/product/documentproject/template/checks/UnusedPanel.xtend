package info.scce.cinco.product.documentproject.template.checks

import info.scce.cinco.product.documentproject.template.mcam.modules.checks.TemplateCheck
import info.scce.cinco.product.documentproject.template.template.Template
import info.scce.cinco.product.documentproject.template.template.Panel
import java.util.ArrayList
import graphmodel.Edge

class UnusedPanel extends TemplateCheck{
	
	override check(Template model) {
		for(panel : model.panels){
			checkUsage(panel)
		}
	}
	
	def checkUsage(Panel panel) {
		if(panel.allIncomingEdges.isNullOrEmpty){
			addWarning(panel, '''No access rights for panel '«panel.name»' defined: This panel will be disabled.''')
		}
	}
	
	def ArrayList<Edge> allIncomingEdges(Panel panel){
		var allEdges = new ArrayList()
		allEdges.addAll(panel.incoming)
		for(field : panel.fields){
			allEdges.addAll(field.incoming)
		}
		return allEdges
	}
	
}