package info.scce.cinco.product.documentproject.views.utils;

import java.util.ArrayList;
import java.util.List;

import info.scce.cinco.product.documentproject.documents.documents.Documents;
import info.scce.cinco.product.documentproject.documents.documents.Role;

public class RoleUtils extends GraphModelUtils {

	public RoleUtils(String[] fileExtensions) {
		super(fileExtensions);
	}
	
	public List<Role> getRoles(Documents model) {
		return model.getRoles();
	}

}
