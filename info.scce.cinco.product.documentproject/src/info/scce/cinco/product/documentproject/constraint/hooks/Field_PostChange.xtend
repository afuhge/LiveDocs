package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoPostAttributeChangeHook
import info.scce.cinco.product.documentproject.constraint.constraint.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.NumberFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.TextFieldConstraint
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.TextField
import org.eclipse.emf.ecore.EStructuralFeature

class Field_PostChange extends CincoPostAttributeChangeHook<FieldConstraint>{
	
	override canHandleChange(FieldConstraint arg0, EStructuralFeature arg1) {
		return true
	}
	
	override handleChange(FieldConstraint field, EStructuralFeature arg1) {
		if(arg1.name == "libraryComponentUID") {
			field.label = field.getFieldLabel
		}
	}
	
	def dispatch getFieldLabel(TextFieldConstraint it){
		return (((it as TextFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint).field as TextField).label
	}
	def dispatch getFieldLabel(NumberFieldConstraint it){
		return (((it as NumberFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint).field as NumberField).label
	}
	def dispatch getFieldLabel(DateFieldConstraint it){
		return (((it as DateFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint).field as DateField).label
	}
	
	def dispatch getFieldLabel(CheckBoxFieldConstraint it){
		return (((it as CheckBoxFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint).field as CheckBoxField).label
	}
	def dispatch getFieldLabel(ChoiceFieldConstraint it){
		return (((it as ChoiceFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint).field as ChoiceField).label
	}
	
}