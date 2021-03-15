package info.scce.cinco.product.documentproject.template.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.template.template.Dependency

class DoubleClick_OpenDependencyModel extends CincoCustomAction<Dependency>{
	
	override execute(Dependency dep) {
		dep.dependency.openEditor
	}
	
}