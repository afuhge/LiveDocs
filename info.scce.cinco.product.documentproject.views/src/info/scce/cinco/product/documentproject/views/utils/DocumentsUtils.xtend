package info.scce.cinco.product.documentproject.views.utils
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.EList
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.Field
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint

class DocumentsUtils extends GraphModelUtils {
	static package Helper ex=new Helper()
	 new(String[] fileExtensions) {
		super(fileExtensions)
	}
	def Iterable<Panel> getPanels(Dependency model) {
		return ex.getAllPanels(model) 
	}
	def List<FieldConstraint> getFieldConstraints(Dependency model) {
		return model.getFieldConstraints() 
	}
	def List<FieldConstraint> getPanelsFieldConstraints(Panel panel) {
		var Dependency model=panel.getRootElement() 
		var ArrayList<FieldConstraint> panelfieldConstraints=new ArrayList<FieldConstraint>() 
		var EList<FieldConstraint> allFieldConstraints=model.getFieldConstraints() 
		var info.scce.cinco.product.documentproject.template.template.Panel templPanel=((panel.getPanel() as info.scce.cinco.product.documentproject.template.template.Panel)) 
		var EList<Field> templPanelFields=templPanel.getFields() 
		for (FieldConstraint fieldConstraint : allFieldConstraints) {
			for(templPanelField : templPanelFields){
				if(fieldConstraint.concreteFieldConstraint.equals(templPanelField.id)){
					panelfieldConstraints.add(fieldConstraint)
				}
			} 
		}
		return panelfieldConstraints 
	}
	
	def String getConcreteFieldConstraint(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint : (constraint as TextFieldConstraint).libraryComponentUID
			NumberFieldConstraint : (constraint as NumberFieldConstraint).libraryComponentUID
			DateFieldConstraint : (constraint as DateFieldConstraint).libraryComponentUID
			CheckBoxFieldConstraint : (constraint as CheckBoxFieldConstraint).libraryComponentUID
			ChoiceFieldConstraint : (constraint as ChoiceFieldConstraint).libraryComponentUID
				
		}
	}
}