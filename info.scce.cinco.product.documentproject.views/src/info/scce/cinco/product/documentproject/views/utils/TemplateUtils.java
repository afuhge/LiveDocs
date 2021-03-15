package info.scce.cinco.product.documentproject.views.utils;

import java.util.List;

import info.scce.cinco.product.documentproject.template.template.Field;
import info.scce.cinco.product.documentproject.template.template.Panel;
import info.scce.cinco.product.documentproject.template.template.Template;

public class TemplateUtils extends GraphModelUtils {

	public TemplateUtils(String[] fileExtensions) {
		super(fileExtensions);
	}
	
	public List<Panel> getPanels(Template model) {
		return model.getPanels();
	}
	
	public List<Field> getFields (Panel panel){
		return panel.getFields();
	}

}
