package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.TextField
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import graphmodel.ModelElementContainer
import graphmodel.Node

class FieldCheck  extends DependencyCheck{
	
	protected extension Helper = new Helper
	override check(Dependency model) {
		for (constraint : model.fieldConstraints){
					var correspondingPanel = findPanel(constraint)
					if(correspondingPanel != null){
						if(!panelIncludesField(correspondingPanel, constraint)){
							addError(model, "panel '" + correspondingPanel.panelName + "' does not contain a field called '" + constraint.fieldName + "'")
						}
					}else{
						addError(constraint, '''Field '«constraint.fieldName» in previous panel is missing.''')
						
					}
					checkCorrespondingFieldIsRequired(constraint)
		}
	}
	
	def checkCorrespondingFieldIsRequired(FieldConstraint constraint) {
		switch (constraint) {
			TextFieldConstraint : 
				if(((constraint as TextFieldConstraint).field as TextField).validation !== null){
					if(!((constraint as TextFieldConstraint).field as TextField).validation.isRequired){
						addError(constraint, "'"+((constraint as TextFieldConstraint).field as TextField).label + "' have to be required (see validation)")
					}
				}else{
					addError(constraint, "'"+((constraint as TextFieldConstraint).field as TextField).label + "' needs validation (see treeview)")
				}
			NumberFieldConstraint: 
				if(((constraint as NumberFieldConstraint).field as NumberField).validation !== null){
					if(!((constraint as NumberFieldConstraint).field as NumberField).validation.isRequired){
						addError(constraint, "'"+((constraint as NumberFieldConstraint).field as NumberField).label + "' have to be required (see validation)")
					}
				}else{
					addError(constraint, "'"+((constraint as NumberFieldConstraint).field as NumberField).label + "' needs validation (see treeview)")
				}
			ChoiceFieldConstraint:
				if(((constraint as ChoiceFieldConstraint).field as ChoiceField).validation !== null){
						if(!((constraint as ChoiceFieldConstraint).field as ChoiceField).validation.isRequired){
							addError(constraint, "'"+((constraint as ChoiceFieldConstraint).field as ChoiceField).label + "' have to be required (see validation)")
						}
				}else{
					addError(constraint, "'"+((constraint as ChoiceFieldConstraint).field as ChoiceField).label + "' needs validation (see treeview)")
				}
			DateFieldConstraint:
				if(((constraint as DateFieldConstraint).field as DateField).validation !== null){
							if(!((constraint as DateFieldConstraint).field as DateField).validation.isRequired){
								addError(constraint, "'"+((constraint as DateFieldConstraint).field as DateField).label + "' have to be required (see validation)")
							}
				}else{
					addError(constraint, "'"+((constraint as DateFieldConstraint).field as DateField).label + "' needs validation (see treeview)")
				}
		}
	}
	
	
	def panelIncludesField(Panel panel, FieldConstraint fieldConstraint) {
		if ((panel.container instanceof XOR)) {
			return true

		} else {
			var templPanel = panel.panel as info.scce.cinco.product.documentproject.template.template.Panel
			for (templField : templPanel.fields) {
				if (fieldConstraint !== null) {
					var fieldID = fieldConstraint.toID
					if (templField.id.equals(fieldID)) {
						return true
					}
				}
			}
			return false
		}
	}
	


	def dispatch toID(TextFieldConstraint it){
		return ((it as TextFieldConstraint).field as TextField).id
	}
	
	def dispatch toID(NumberFieldConstraint it){
		return ((it as NumberFieldConstraint).field as NumberField).id
	}
	
	def dispatch toID(DateFieldConstraint it){
		 return ((it as DateFieldConstraint).field as DateField).id
	}
	
	def dispatch toID (CheckBoxFieldConstraint it){
		return ((it as CheckBoxFieldConstraint).field as CheckBoxField).id
	}
	
	def dispatch toID(ChoiceFieldConstraint it){
		return ((it as ChoiceFieldConstraint ).field as ChoiceField).id
	}
	
	def dispatch getFieldName(TextFieldConstraint  it){
		return ((it as TextFieldConstraint ).field as TextField).label
	}
	def dispatch getFieldName(NumberFieldConstraint  it){
		return ((it as NumberFieldConstraint ).field as NumberField).label
	}
	def dispatch getFieldName(DateFieldConstraint  it){
		return ((it as DateFieldConstraint ).field as DateField).label
	}
	def dispatch getFieldName(CheckBoxFieldConstraint  it){
		return ((it as CheckBoxFieldConstraint ).field as CheckBoxField).label
	}
	def dispatch getFieldName(ChoiceFieldConstraint  it){
		return ((it as ChoiceFieldConstraint ).field as ChoiceField).label
	}

	
	def getPanelName(Panel panel)'''«(panel.panel as info.scce.cinco.product.documentproject.template.template.Panel).name»'''
	
	
	def dispatch findPanel(TextFieldConstraint fieldConstraint) {
		if(!fieldConstraint.incomingPanelToTextFieldConstraints.isNullOrEmpty){
			if(fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement instanceof Panel){
				return fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement as Panel
			}else if(fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement instanceof AND){
				var and = fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement as AND
				for(panel1 : and.panels){
					for(field : panel1.tmplPanel.fields){
						if(field.label.equals(fieldConstraint.label)){
							return panel1
						}
					}
				}
			}
			else if(fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement instanceof OR){
				var or = fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement as OR
				for(panel1 : or.panels){
					for(field : panel1.tmplPanel.fields){
						if(field.label.equals(fieldConstraint.label)){
							return panel1
						}
					}
				}
			}
			else if(fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement instanceof XOR){
				var xor = fieldConstraint.incomingPanelToTextFieldConstraints.get(0).sourceElement as XOR
				for(panel1 : xor.panels){
					for(field : panel1.tmplPanel.fields){
						if(field.label.equals(fieldConstraint.label)){
							return panel1
						}
					}
				}
			}
		}
	}
	
	def dispatch findPanel(NumberFieldConstraint fieldConstraint) {
		if (fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement instanceof Panel) {
			return fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement as Panel
		} else if (fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement instanceof AND) {
			var and = fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement as AND
			for (panel1 : and.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		} else if (fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement instanceof OR) {
			var or = fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement as OR
			for (panel1 : or.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
		else if (fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement instanceof XOR) {
			var xor = fieldConstraint.incomingPanelToNumberFieldConstraints.get(0).sourceElement as XOR
			for (panel1 : xor.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
	}
	
	def dispatch findPanel(CheckBoxFieldConstraint fieldConstraint) {
		if (fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement instanceof Panel) {
			return fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement as Panel
		} else if (fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement instanceof AND) {
			var and = fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement as AND
			for (panel1 : and.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		} else if (fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement instanceof OR) {
			var or = fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement as OR
			for (panel1 : or.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
		else if (fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement instanceof XOR) {
			var xor = fieldConstraint.incomingPanelToCheckboxFieldConstraints.get(0).sourceElement as XOR
			for (panel1 : xor.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
	}
	
	def dispatch findPanel(DateFieldConstraint fieldConstraint) {
		if (fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement instanceof Panel) {
			return fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement as Panel
		} else if (fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement instanceof AND) {
			var and = fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement as AND
			for (panel1 : and.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		} else if (fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement instanceof OR) {
			var or = fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement as OR
			for (panel1 : or.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
		else if (fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement instanceof XOR) {
			var xor = fieldConstraint.incomingPanelToDateFieldConstraints.get(0).sourceElement as XOR
			for (panel1 : xor.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
	}
	
	def dispatch findPanel(ChoiceFieldConstraint fieldConstraint) {
		if (fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement instanceof Panel) {
			return fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement as Panel
		} else if (fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement instanceof AND) {
			var and = fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement as AND
			for (panel1 : and.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		} else if (fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement instanceof OR) {
			var or = fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement as OR
			for (panel1 : or.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
		else if (fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement instanceof XOR) {
			var xor = fieldConstraint.incomingPanelToChoiceFieldConstraints.get(0).sourceElement as XOR
			for (panel1 : xor.panels) {
				for (field : panel1.tmplPanel.fields) {
					if (field.label.equals(fieldConstraint.label)) {
						return panel1
					}
				}
			}
		}
	}
	
	
}