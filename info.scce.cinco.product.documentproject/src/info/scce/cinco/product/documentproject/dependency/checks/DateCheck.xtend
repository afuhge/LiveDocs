package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.generator.Helper

class DateCheck extends DependencyCheck{
	protected extension Helper = new Helper
	
	override check(Dependency model) {
		for ( dateField : model.dateFieldConstraints){
			checkAllValuesSet(dateField)
			checkCorrectValuesSet(dateField)
		}
	}
	
	def checkCorrectValuesSet(DateFieldConstraint constraint) {
		switch(constraint.toDate){
			case "02-30" : addError(constraint, "Incorrect date.")
			case "02-31"  : addError(constraint, "Incorrect date.")
			case "04-31"  : addError(constraint, "Incorrect date.")
			case "06-31"  : addError(constraint, "Incorrect date.")
			case "09-31"  : addError(constraint, "Incorrect date.")
			case "11-31"  : addError(constraint, "Incorrect date.")
		}
	}
	
	def getToDate(DateFieldConstraint constraint){
		return '''«constraint.date_month.toDigit»-«constraint.date_day.escapeZero»'''
	}
	
	def checkAllValuesSet(DateFieldConstraint constraint) {
		if(constraint.date_day.isNullOrEmpty){
			addError(constraint, "To use DateFieldConstraint correctly, 'date_day' should be selected.")
		}
		if(constraint.date_month.isNullOrEmpty){
			addError(constraint, "To use DateFieldConstraint correctly, 'date_month' should be selected.")
		}
		if(constraint.date_year.isNullOrEmpty){
			addError(constraint, "To use DateFieldConstraint correctly, 'date_year' should be selected.")
		}
	}
	
}