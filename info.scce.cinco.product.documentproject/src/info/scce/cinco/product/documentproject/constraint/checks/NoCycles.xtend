package info.scce.cinco.product.documentproject.constraint.checks

import graphmodel.Node
import info.scce.cinco.product.documentproject.constraint.constraint.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.Conclusion
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.NumberFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.Panel
import info.scce.cinco.product.documentproject.constraint.constraint.Premise
import info.scce.cinco.product.documentproject.constraint.constraint.TextFieldConstraint
import info.scce.cinco.product.documentproject.constraint.mcam.modules.checks.ConstraintCheck
import org.eclipse.emf.common.util.EList

class NoCycles extends ConstraintCheck{
	
	//keine selbstkanten
	//keine A -> B -> A
	
	override check(Constraint model) {
		checkCyclesPremises(model.premises, model)
		checkCyclesConclusions(model.conclusions, model)
		checkPatternCycles(model.premises)
	}
	
	// no A -> B -> A
	def checkPatternCycles(EList<Premise> list) {
		for(premise : list){
			for(panel : premise.panels){
				if(!panel.outgoing.isEmpty){
					for(edge : panel.outgoing){
						var target = edge.targetElement
						if(!target.outgoing.isEmpty){
							for(edge2 : target.outgoing){
								var nextTarget = edge2.targetElement
								if(panel.id.equals(nextTarget.id)){
									addError(panel, '''Panel '«(panel.panel as info.scce.cinco.product.documentproject.dependency.dependency.Panel).name»' has a cycle with another element in premise.''')
								}
							}
						}
					}
				}
			}
			for(field : premise.fieldConstraints){
				if(!field.outgoing.isEmpty){
					for(edge : field.outgoing){
						var target = edge.targetElement
						if(!target.outgoing.isEmpty){
							for(edge2 : target.outgoing){
								var nextTarget = edge2.targetElement
								if(field.id.equals(nextTarget.id)){
									addError(field, '''FieldConstraint '«field.name»' has a cycle with another element in premise.''')
								}
							}
						}
					}
				}
			}
		}
	}
	
	def checkCyclesConclusions(EList<Conclusion> conclusions, Constraint model) {
		for(conclusion : conclusions){
			checkCyclesOfPanels(conclusion.panels, model)
			checkCyclesOfFieldConstraint(conclusion.fieldConstraints, model)
			checkCycle(conclusion, model)
		}
		
	}
	
	def checkCyclesPremises(EList<Premise> premises, Constraint model) {
		for(premise : premises){
			checkCyclesOfPanels(premise.panels, model)
			checkCyclesOfFieldConstraint(premise.fieldConstraints, model)
			checkCycle(premise, model)
		}
	}
	
	def checkCyclesOfFieldConstraint(EList<FieldConstraint> list, Constraint model) {
		list.forEach[checkCycle(model)]
	}
	
	def checkCyclesOfPanels(EList<Panel> list, Constraint model) {
		list.forEach[checkCycle(model)]
	}
	
	def checkCycle(Node node, Constraint model) {
		if(!node.outgoing.isEmpty){
			if(node.outgoing.get(0).targetElement.equals(node)){
				addError(model, "Cycle detected. source and target node should be different. ")	
			}
		}
	}
	
	private def String getName(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint : ((constraint as TextFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint).label
			NumberFieldConstraint : ((constraint as NumberFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint).label
			DateFieldConstraint : ((constraint as DateFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint).label
			CheckBoxFieldConstraint : ((constraint as NumberFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint).label
			ChoiceFieldConstraint : ((constraint as ChoiceFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint).label
		}
	}
	
}