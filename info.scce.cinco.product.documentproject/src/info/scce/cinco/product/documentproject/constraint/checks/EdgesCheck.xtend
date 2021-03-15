package info.scce.cinco.product.documentproject.constraint.checks

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
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.TextField
import org.eclipse.emf.common.util.EList

class EdgesCheck extends ConstraintCheck {
	// keine kante von panels auf panels in anderen containern
	override check(Constraint model) {
		checkIncomingOutgoingEdgesPremise(model.premises)
		checkIncomingOutgoingEdgesConclusion(model.conclusions)
	}

	private def checkIncomingOutgoingEdgesConclusion(EList<Conclusion> list) {
		for (conclusion : list) {
			for (panel : conclusion.panels) {
				var panelContainerID = panel.container.id
				checkOutgoing(panelContainerID, panel)
				checkIncoming(panelContainerID, panel)
			}
			for (field : conclusion.fieldConstraints) {
				var fieldContainerID = field.container.id
				checkOutgoing(fieldContainerID, field)
				checkIncoming(fieldContainerID, field)
			}
		}
	}

	private def checkIncomingOutgoingEdgesPremise(EList<Premise> list) {
		for (premise : list) {
			for (panel : premise.panels) {
				var panelContainerID = panel.container.id
				checkOutgoing(panelContainerID, panel)
				checkIncoming(panelContainerID, panel)
			}
			for (field : premise.fieldConstraints) {
				var fieldContainerID = field.container.id
				checkOutgoing(fieldContainerID, field)
				checkIncoming(fieldContainerID, field)
			}
		}
	}

	private def dispatch checkIncoming(String panelContainerID, Panel panel) {
		if (!panel.incoming.isEmpty) {
			for (edge : panel.incoming) {
				var containerSourceID = edge.sourceElement.container.id
				if (!panelContainerID.equals(containerSourceID)) {
					addError(
						panel, '''Panel '«(panel.panel as info.scce.cinco.product.documentproject.dependency.dependency.Panel).name»' in Premise should not have any incoming edges from elements in other containers.''')
				}
			}
		}
	}

	private def dispatch checkIncoming(String panelContainerID, FieldConstraint field) {
		if (!field.incoming.isEmpty) {
			for (edge : field.incoming) {
				var containerSourceID = edge.sourceElement.container.id
				if (!panelContainerID.equals(containerSourceID)) {
					addError(
						field, '''FieldConstraint '«field.name»' in Premise should not have any incoming edges from elements in other containers.''')
				}
			}
		}
	}
	
	def String getName(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint : (((constraint as TextFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint).field as TextField).label
			NumberFieldConstraint : (((constraint as NumberFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint).field as NumberField).label
			DateFieldConstraint : (((constraint as DateFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint).field as DateField).label
			CheckBoxFieldConstraint : (((constraint as CheckBoxFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint).field as CheckBoxField).label
			ChoiceFieldConstraint : (((constraint as ChoiceFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint).field as ChoiceField).label
		}
	}

	private def dispatch checkOutgoing(String panelContainerID, Panel panel) {
		if (!panel.outgoing.isEmpty) {
			for (edge : panel.outgoing) {
				var containerTargetID = edge.targetElement.container.id
				if (!panelContainerID.equals(containerTargetID)) {
					addError(
						panel, '''Panel '«(panel.panel as info.scce.cinco.product.documentproject.dependency.dependency.Panel).name»' in Premise should not have any outgoing edges to elements in other containers.''')
				}
			}
		}
	}

	private def dispatch checkOutgoing(String panelContainerID, FieldConstraint field) {
		if (!field.outgoing.isEmpty) {
			for (edge : field.outgoing) {
				var containerTargetID = edge.targetElement.container.id
				if (!panelContainerID.equals(containerTargetID)) {
					addError(
						field, '''FieldConstraint in Premise should not have any outgoing edges to elements in other containers.''')
				}
			}
		}
	}


}
