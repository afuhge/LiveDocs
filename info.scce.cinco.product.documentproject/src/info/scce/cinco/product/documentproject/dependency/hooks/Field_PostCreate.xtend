package info.scce.cinco.product.documentproject.dependency.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.TextField

class Field_PostCreate extends CincoPostCreateHook<FieldConstraint> {

	override postCreate(FieldConstraint field) {
		field.label = field.getFieldLabel
	}

	def dispatch getFieldLabel(TextFieldConstraint it){
		return ((it as TextFieldConstraint).field as TextField).label
	}
	def dispatch getFieldLabel(NumberFieldConstraint it){
		return ((it as NumberFieldConstraint).field as NumberField).label
	}
	def dispatch getFieldLabel(DateFieldConstraint it){
		return ((it as DateFieldConstraint).field as DateField).label
	}
	
	def dispatch getFieldLabel(CheckBoxFieldConstraint it){
		return ((it as CheckBoxFieldConstraint).field as CheckBoxField).label
	}
	def dispatch getFieldLabel(ChoiceFieldConstraint it){
		return ((it as ChoiceFieldConstraint).field as ChoiceField).label
	}

}
