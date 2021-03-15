package info.scce.cinco.product.documentproject.dependency.hooks

import de.jabc.cinco.meta.runtime.action.CincoPostAttributeChangeHook
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import org.eclipse.emf.ecore.EStructuralFeature

class SetName extends CincoPostAttributeChangeHook<Panel>{
	
	override canHandleChange(Panel arg0, EStructuralFeature arg1) {
		true
	}
	
	override handleChange(Panel panel, EStructuralFeature arg1) {
		if(arg1.name == "libraryComponentUID"){
			var tempPanel = panel.panel as info.scce.cinco.product.documentproject.template.template.Panel
			panel.name = tempPanel.name
		}
	}
	
}