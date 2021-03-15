package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import java.util.ArrayList
import graphmodel.Node

class StartPanelCheck extends DependencyCheck{
	
	override check(Dependency model) {
		var ArrayList<Node> modelelementsWithoutIncomingEdges = new ArrayList()
		modelelementsWithoutIncomingEdges.addAll(model.ANDs.filter[incoming.isEmpty])
		modelelementsWithoutIncomingEdges.addAll(model.panels.filter[incoming.isEmpty])
		modelelementsWithoutIncomingEdges.addAll(model.ORs.filter[incoming.isEmpty])
		modelelementsWithoutIncomingEdges.addAll(model.XORs.filter[incoming.isEmpty])
		
		if(modelelementsWithoutIncomingEdges.length > 1){
			addError(model, '''No unqiue start panel: Make sure that you only have one element without incoming edges.''')
		}
	}
	
}