package info.scce.cinco.product.documentproject.generator

import graphmodel.Node
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.documents.documents.Document
import java.util.ArrayList
import java.util.List
import graphmodel.ModelElementContainer
import info.scce.cinco.product.documentproject.dependency.dependency.Constraints

class DTD_Helper {
	static extension Helper = new Helper
	
	def generateDocumentTypDeclaration(Document doc)'''
	<!DOCTYPE  «(doc.dependency as Dependency).escape.toLowerCase.replace("_","-")» [
	'''
		
	def dispatch ArrayList<Panel> childs(OR or){
		var all = new ArrayList<Panel>()
		all.addAll(or.panels)
		return all
	}
	
	def  dispatch ArrayList<Panel> childs(AND and){
		var all = new ArrayList<Panel>()
		all.addAll(and.panels)
		return all
	}
	
	def  dispatch ArrayList<Panel> childs(XOR xor){
		var all = new ArrayList<Panel>()
		all.addAll(xor.panels)
		return all
	}
	
	def  dispatch ArrayList<Node> childs(Panel panel){
		var all = new ArrayList<Node>()
		if(panelIsInAnd(panel)){
			//if panel is last panel then add succssor 
			if((panel.container as AND).panels.last.equals(panel)){
				all.addAll(getANDSuccessors((panel.container as AND)))
			}
		}
		else if(panelIsInOr(panel)){
			all.addAll(getORSuccessors((panel.container as OR)))
		}
		else if(panelIsInXOR(panel)){
			all.addAll(getXORSuccessors((panel.container as XOR)))
		}
		if(panel.panelHasANDSuccesor){
			all.addAll(panel.ANDSuccessors)
		}
		if(panel.panelHasORSuccesor){
			all.addAll(panel.ORSuccessors)
		}
		if(panel.panelHasXORSuccesor){
			all.addAll(panel.XORSuccessors)
		}
		if(panel.outgoingElses.isNullOrEmpty){
			if(panel.outgoingPanelToConstraints.isNullOrEmpty){
				all.addAll(panel.panelSuccessors)
			}
		}
		return all
	}
	
	def generateField(Panel panel){
		var String field = ""
		if(!panel.tmplPanel.fields.isNullOrEmpty){
			if(panel.tmplPanel.fields.size == 1){
				field = "field"
			}else if(panel.tmplPanel.fields.size > 1){
				field = "field+"
			}
		}
		
		return field
	}
	
	def getNodesWithPreCondition(Document doc){
		var ArrayList<Node> nodes = new ArrayList<Node>()
		for(node : doc.allElements){
			if(node instanceof AND){
				if(!(node as AND).fieldConstraintPredecessors.isNullOrEmpty){
					nodes.add(node)
				}
				if(!(node as AND).incomingElses.isNullOrEmpty){
					nodes.add(node)
				}
			}else if(node instanceof OR){
				if(!(node as OR).fieldConstraintPredecessors.isNullOrEmpty){
					nodes.add(node)
				}
				if(!(node as OR).incomingElses.isNullOrEmpty){
					nodes.add(node)
				}
			}else if(node instanceof XOR){
				if(!(node as XOR).fieldConstraintPredecessors.isNullOrEmpty){
					nodes.add(node)
				}
				if(!(node as XOR).incomingElses.isNullOrEmpty){
					nodes.add(node)
				}
			}else if(node instanceof Panel){
				if(!(node as Panel).fieldConstraintPredecessors.isNullOrEmpty){
					nodes.add(node)
				}
				if(!(node as Panel).incomingElses.isNullOrEmpty){
					nodes.add(node)
				}
			}
		}
		return nodes
	}
	
	
	def  getchilds(FieldConstraint constraint){
		var all = new ArrayList<Node>()
		if(constraint.panelHasANDSuccesor){
			all.addAll(constraint.ANDSuccessors)
		}
		if(constraint.panelHasORSuccesor){
			all.addAll(constraint.ORSuccessors)
		}
		if(constraint.panelHasXORSuccesor){
			all.addAll(constraint.XORSuccessors)
		}
		all.addAll(constraint.panelSuccessors)
		return all
	}
	
	def  findFirstPanel(Dependency dep) {
		for(and : dep.ANDs){
			if(and.incoming.isEmpty){
				return and
			}
		}
		for(or : dep.ORs){
			if(or.incoming.isEmpty){
				return or
			}
		}
		for(xor : dep.XORs){
			if(xor.incoming.isEmpty){
				return xor
			}
		}
		for(panel : dep.panels){
			if(panel.incoming.isEmpty){
				return panel as Panel
			}
		}
	}
	
	
	def getAllPanelsInAnd(FieldConstraint constraint) {
		var allPanels = new ArrayList<Panel>()
		var ands =constraint.ANDSuccessors
		for(and : ands){
			allPanels.addAll(and.panels)
		}
		return allPanels
	}
	
	def getAllPanelsInXOR(FieldConstraint constraint) {
		var allPanels = new ArrayList<Panel>()
		var xors =constraint.XORSuccessors
		for(xor : xors){
			allPanels.addAll(xor.panels)
		}
		return allPanels
	}
	
	def getAllPanelsInOr(FieldConstraint constraint) {
		var allPanels = new ArrayList<Panel>()
		var ors =constraint.ORSuccessors
		for(or : ors){
			allPanels.addAll(or.panels)
		}
		return allPanels
	}
	
	
	def boolean panelHasXORSuccesor(FieldConstraint panel){
		if(!panel.XORSuccessors.isNullOrEmpty){
			return true
		}
		else{
			return false;
		}
	}
	
	def boolean panelHasORSuccesor(FieldConstraint panel){
		if(!panel.ORSuccessors.isNullOrEmpty){
			return true
		}
		else{
			return false;
		}
	}
	
	
	def boolean panelHasANDSuccesor(FieldConstraint panel){
		if(!panel.ANDSuccessors.isNullOrEmpty){
			return true
		}
		else{
			return false;
		}
	}
	
	def getAllPanelsInXOR(Panel panel) {
		var allPanels = new ArrayList<Panel>()
		var xors =panel.XORSuccessors
		var edges = panel.outgoingPanelToConstraints
		for(edge : edges){
			var field = edge.targetElement
			var xors2 = field.XORSuccessors
			for(xor : xors2){
				allPanels.addAll(xor.panels)
			}
		}
		for(xor : xors){
			allPanels.addAll(xor.panels)
		}
		return allPanels
	}
	
	def getAllPanelsInOr(Panel panel) {
		var allPanels = new ArrayList<Panel>()
		var ors =panel.ORSuccessors
		var edges = panel.outgoingPanelToConstraints
		for(edge : edges){
			var field = edge.targetElement
			var ors2 = field.ORSuccessors
			for(or : ors2){
				allPanels.addAll(or.panels)
			}
		}
		for(or : ors){
			allPanels.addAll(or.panels)
		}
		return allPanels
	}
	def boolean panelHasXORSuccesor(Panel panel){
		if(!panel.XORSuccessors.isNullOrEmpty){
			return true
		}
		else{
			return false;
		}
	}
	
	def boolean panelHasORSuccesor(Panel panel){
		if(!panel.ORSuccessors.isNullOrEmpty){
			return true
		}
		else{
			return false;
		}
	}
	
	def getAllPanelsInAnd(Panel panel) {
		var allPanels = new ArrayList<Panel>()
		var ands =panel.ANDSuccessors
		var edges = panel.outgoingPanelToConstraints
		for( edge : edges){
			var field = edge.targetElement
			var ands2 = field.ANDSuccessors
			for(and : ands2){
			allPanels.addAll(and.panels)
		}
		}
		for(and : ands){
			allPanels.addAll(and.panels)
		}
		return allPanels
	}
	
	def panelIsInAnd(Panel panel) {
		if(panel.container instanceof AND){
			return true
		}
		else{
			return false
		}
	}
	
	
	def panelIsInOr(Panel panel) {
		if(panel.container instanceof OR){
			return true
		}
		else{
			return false
		}
	}
	
	def panelIsInXOR(Panel panel) {
		if(panel.container instanceof XOR){
			return true
		}
		else{
			return false
		}
	}
	
	def boolean panelHasANDSuccesor(Panel panel){
		if(!panel.ANDSuccessors.isNullOrEmpty){
			return true
		}
		else{
			return false;
		}
	}
	
	
	def ArrayList<Node> getORSuccessors(OR or){
		var ArrayList<Node> successors = new ArrayList()
		for(edge : or.outgoing){
			switch(edge.targetElement){
			Panel: successors.add(edge.targetElement as Panel)
				FieldConstraint: successors.addAll((edge.targetElement as FieldConstraint).getchilds)
				AND: successors.addAll(edge.targetElement as AND)
				OR: successors.addAll(edge.targetElement as OR)
				XOR : successors.addAll(edge.targetElement as XOR)
			}
		}
		return successors
	}
	
	def ArrayList<Node> getANDSuccessors(AND and){
		var ArrayList<Node> successors = new ArrayList()
		for(edge : and.outgoing){
			switch(edge.targetElement){
				Panel: successors.add(edge.targetElement as Panel)
				FieldConstraint: successors.addAll((edge.targetElement as FieldConstraint).getchilds)
				AND: successors.addAll(edge.targetElement as AND)
				OR: successors.addAll(edge.targetElement as OR)
				XOR : successors.addAll(edge.targetElement as XOR)
			}
		}
		return successors
	}
	
	def ArrayList<Node> getXORSuccessors(XOR xor){
		var ArrayList<Node> successors = new ArrayList()
		for(edge : xor.outgoing){
			switch(edge.targetElement){
				Panel: successors.add(edge.targetElement as Panel)
				FieldConstraint: successors.addAll((edge.targetElement as FieldConstraint).getchilds)
				AND: successors.addAll(edge.targetElement as AND)
				OR: successors.addAll(edge.targetElement as OR)
				XOR : successors.addAll(edge.targetElement as XOR)
			}
		}
		return successors
	}
	
	def getAllElements(Document doc){
		var dep = doc.dependency as Dependency
		var ArrayList<Node> allElements = new ArrayList<Node>()
		allElements.addAll(doc.panels)
		allElements.addAll(dep.nodes.filter[!(it instanceof FieldConstraint) && ! (it instanceof Panel) && !(it instanceof Constraints)])
		return allElements
	}
	
	def elementHasField(List<Panel> panels) {
		var hasField = false;
		for(panel :panels){
			if(!panel.tmplPanel.fields.isNullOrEmpty){
				return true
			}
		}
		return hasField
	}
	
	def getElementName(Node node){
		switch(node){
			XOR: return '''xor-«(node as XOR).id.toLowerCase.replace("_","-")»'''
			OR: return '''or«(node as OR).id.toLowerCase.replace("_","-")»'''
			AND : return '''and«(node as AND).id.toLowerCase.replace("_","-")»'''
			Panel: return '''«(node as Panel).escape.toLowerCase.replace("_","-")»'''
		}
	}

	def getTagName(Node node){
		switch(node){
			AND: '''and«(node as AND).id.toLowerCase.replace("_","-")»'''
			XOR:'''xor-«(node as XOR).id.toLowerCase.replace("_","-")»'''
			OR:'''or«(node as OR).id.toLowerCase.replace("_","-")»'''
			Panel : '''«(node as Panel).escape.toLowerCase.replace("_","-")»'''
		}
	}
	
	
	
	
	def boolean hasElse(Node container){
		if(container instanceof XOR){
			var xor = container as XOR
			if(!xor.outgoingElses.isNullOrEmpty){
				return true;
			}else if(!xor.outgoingPanelToConstraints.isNullOrEmpty){
				return true;
			}
			else{
				return false
			}
		}else if(container instanceof OR){
			var or = container as OR
			if(!or.outgoingElses.isNullOrEmpty){
				return true;
			}else if(!or.outgoingPanelToConstraints.isNullOrEmpty){
				return true;
			}else{
				return false
			}
		}else if(container instanceof AND){
			var and = container as AND
			if(!and.outgoingElses.isNullOrEmpty){
				return true;
			}else if(!and.outgoingPanelToConstraints.isNullOrEmpty){
				return true;
			}else{
				return false
			}
		}else if(container instanceof Panel){
			var panel = container as Panel
			if(!panel.outgoingElses.isNullOrEmpty){
				return true;
			}else if(!panel.outgoingPanelToConstraints.isNullOrEmpty){
				return true;
			}else{
				return false
			}
		}
		else{
			return false;
		}
	}
	
	def dispatch generateSimpleChilds(Panel container) '''«IF container.hasElse»«FOR panel : (container).childs BEFORE "(" SEPARATOR ", " AFTER ")"»«panel.tagName»?«ENDFOR»«ELSE»«FOR panel : (container).childs BEFORE "(" SEPARATOR ", " AFTER ")"»«panel.tagName»«ENDFOR»«ENDIF»'''
	def dispatch generateSimpleChilds(XOR container) '''«FOR panel : (container).childs BEFORE "(" SEPARATOR " | " AFTER ")"»«panel.tagName»«ENDFOR»'''
	def dispatch generateSimpleChilds(OR container) '''«FOR panel : (container).childs BEFORE "(" SEPARATOR ", " AFTER ")"»«panel.tagName»?«ENDFOR»'''
	def dispatch generateSimpleChilds(AND container) '''«FOR panel : (container).childs BEFORE "(" SEPARATOR ", " AFTER ")"»«panel.tagName»«ENDFOR»'''
	
	//----------------ELSE -------------------------------------------------------------------------------------------------------------
	def dispatch generateElses(AND container)'''«FOR node : generateElse(container) BEFORE "(" SEPARATOR ", " AFTER ") "»«node.tagName»?«ENDFOR»'''
	def dispatch generateElses(OR container)'''«FOR node : generateElse(container) BEFORE "(" SEPARATOR ", " AFTER ") "»«node.tagName»?«ENDFOR»'''
	def dispatch generateElses(XOR container)'''«FOR node : generateElse(container) BEFORE "(" SEPARATOR ", " AFTER ") "»«node.tagName»?«ENDFOR»'''
	def dispatch generateElses(Panel container)'''«FOR node : generateElse(container) BEFORE "(" SEPARATOR ", " AFTER ") "»«node.tagName»?«ENDFOR»'''
	
	
	def dispatch generateElse(Panel panel) {
		var all = new ArrayList<Node>()
		if (!panel.outgoingElses.isNullOrEmpty) {
			var edge = panel.outgoingElses.get(0)
			var target = edge.targetElement
			var Node targetElse = null
			var foundElements = new ArrayList<Node>()
			switch (target) {
				AND: targetElse = (target as AND)
				OR: targetElse =(target as OR)
				XOR: targetElse = (target as XOR)
				Panel: targetElse = (target as Panel)
			}

			var constraintEdges = panel.outgoingPanelToConstraints
			for (constraintEdge : constraintEdges) {
				var field = constraintEdge.targetElement
				foundElements.addAll(field.getchilds)
			}
			foundElements.add(targetElse)
			all.addAll(foundElements)
		} else {
			if (!panel.outgoingPanelToConstraints.isNullOrEmpty){
				var edges = panel.outgoingPanelToConstraints
				for (edge : edges) {
					var field = edge.targetElement
					all.addAll(field.getchilds)
				}
			}
		}
		return all
	}
	
	def dispatch generateElse(AND and) {
		var all = new ArrayList<Node>()
		if (!and.outgoingElses.isNullOrEmpty) {
			var edge = and.outgoingElses.get(0)
			var target = edge.targetElement
			var Node targetElse = null
			var foundElements = new ArrayList<Node>()
			switch (target) {
				AND: targetElse = (target as AND)
				OR: targetElse =(target as OR)
				XOR: targetElse = (target as XOR)
				Panel: targetElse = (target as Panel)
			}

			var constraintEdges = and.outgoingPanelToConstraints
			for (constraintEdge : constraintEdges) {
				var field = constraintEdge.targetElement
				foundElements.addAll(field.getchilds)
			}
			foundElements.add(targetElse)
			all.addAll(foundElements)
		} else {
			if (!and.outgoingPanelToConstraints.isNullOrEmpty){
				var edges = and.outgoingPanelToConstraints
				for (edge : edges) {
					var field = edge.targetElement
					all.addAll(field.getchilds)
				}
			}
		}
		return all
	}
	
	def dispatch generateElse(OR or) {
		var all = new ArrayList<Node>()
		if (!or.outgoingElses.isNullOrEmpty) {
			var edge = or.outgoingElses.get(0)
			var target = edge.targetElement
			var Node targetElse = null
			var foundElements = new ArrayList<Node>()
			switch (target) {
				AND: targetElse = (target as AND)
				OR: targetElse =(target as OR)
				XOR: targetElse = (target as XOR)
				Panel: targetElse = (target as Panel)
			}

			var constraintEdges = or.outgoingPanelToConstraints
			for (constraintEdge : constraintEdges) {
				var field = constraintEdge.targetElement
				foundElements.addAll(field.getchilds)
			}
			foundElements.add(targetElse)
			all.addAll(foundElements)
		} else {
			if (!or.outgoingPanelToConstraints.isNullOrEmpty){
				var edges = or.outgoingPanelToConstraints
				for (edge : edges) {
					var field = edge.targetElement
					all.addAll(field.getchilds)
				}
			}
		}
		return all
	}
	
	
		
	def dispatch generateElse(XOR xor) {
		var all = new ArrayList<Node>()
		if (!xor.outgoingElses.isNullOrEmpty) {
			var edge = xor.outgoingElses.get(0)
			var target = edge.targetElement
			var Node targetElse = null
			var foundElements = new ArrayList<Node>()
			switch (target) {
				AND: targetElse = (target as AND)
				OR: targetElse =(target as OR)
				XOR: targetElse = (target as XOR)
				Panel: targetElse = (target as Panel)
			}

			var constraintEdges = xor.outgoingPanelToConstraints
			for (constraintEdge : constraintEdges) {
				var field = constraintEdge.targetElement
				foundElements.addAll(field.getchilds)
			}
			foundElements.add(targetElse)
			all.addAll(foundElements)
		} else {
			if (!xor.outgoingPanelToConstraints.isNullOrEmpty){
				var edges = xor.outgoingPanelToConstraints
				for (edge : edges) {
					var field = edge.targetElement
					all.addAll(field.getchilds)
				}
			}
		}
		return all
	}
	
}