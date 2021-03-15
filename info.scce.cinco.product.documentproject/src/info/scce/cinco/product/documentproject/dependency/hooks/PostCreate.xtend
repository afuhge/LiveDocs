package info.scce.cinco.product.documentproject.dependency.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import org.eclipse.emf.common.util.EList
import info.scce.cinco.product.documentproject.dependency.dependency.XOR

class PostCreate extends CincoPostCreateHook<Panel> {
	val OFFSET = 15
	val Y = 25

	override postCreate(Panel dep) {
		if (dep.container instanceof AND) {
			var and = dep.container as AND
			and.width = and.panels.layout
		}else if (dep.container instanceof OR){
			var or  = dep.container as OR
			or.width = or.panels.layout
		}
		else if(dep.container instanceof XOR){
			var xor  = dep.container as XOR
			xor.width = xor.panels.layout
		}
		dep.name = (dep.panel as info.scce.cinco.product.documentproject.template.template.Panel).name
	}
	
	def layout(EList<Panel> list){
		var x = 10
		for(element : list){
			element.moveTo(element.container, x, Y )
			x = x + element.width + OFFSET
		}
		return x
	}

	

}
