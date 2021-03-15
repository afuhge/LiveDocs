package info.scce.cinco.product.documentproject.dependency.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostSaveHook
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import de.jabc.cinco.meta.runtime.xapi.WorkspaceExtension

class SetDependencyName extends CincoPostSaveHook<Dependency>{
	static extension WorkspaceExtension = new WorkspaceExtension
	override postSave(Dependency dep) {
		if(dep.name.isNullOrEmpty){
			var file = activeEditor.file
			var fileName = file.fullPath.segment(1).replace(".dependency","")
			dep.name = fileName
			dep.internalElement.save
		}
	}
	
}