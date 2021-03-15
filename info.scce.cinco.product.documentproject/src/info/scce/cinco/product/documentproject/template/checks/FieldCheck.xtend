package info.scce.cinco.product.documentproject.template.checks

import info.scce.cinco.product.documentproject.template.mcam.modules.checks.TemplateCheck
import info.scce.cinco.product.documentproject.template.template.Template
import info.scce.cinco.product.documentproject.template.template.ChoiceField

class FieldCheck extends TemplateCheck {
	
	override check(Template model) {
		for(panel : model.panels){
			for(field : panel.fields){
				if(field instanceof ChoiceField){
					var choice = field as ChoiceField
					if(choice.content.isNullOrEmpty){
						addError(choice, '''The content of ChoiceField '«field.label»' in Panel '«panel.name»' should not be empty. ''')
					}
				}
				
			}
		}
	}
	
}