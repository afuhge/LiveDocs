package info.scce.cinco.product.documentproject.dependency.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostDeleteHook
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.XOR

class PostDelete extends CincoPostDeleteHook<Panel> {
	val OFFSET = 15
	val Y = 25
	
	override getPostDeleteFunction(Panel templ) {
		if (templ.container instanceof AND) {
			val and = templ.container as AND
			return [and.layout]
		}else if (templ.container instanceof OR){
			val or  = templ.container as OR
			return [or.layout]
		}else if (templ.container instanceof XOR){
			val xor  = templ.container as XOR
			return [xor.layout]
		}
	}

	def void layout(AND and) {
		var x = 10
		if(!and.panels.empty){
			for(element : and.panels){
				element.moveTo(element.container, x, Y )
				x = x + element.width + OFFSET
			}
		}else{
			x = 100
		}
		and.width = x
	}
	
	def void layout(XOR xor) {
		var x = 10
		if(!xor.panels.empty){
			for(element : xor.panels){
				element.moveTo(element.container, x, Y )
				x = x + element.width + OFFSET
			}
		}else{
			x = 100
		}
		xor.width = x
	}
	
	def void layout(OR or) {
		var x = 10
		if(!or.panels.empty){
			for(element : or.panels){
				element.moveTo(element.container, x, Y )
				x = x + element.width + OFFSET
			}
		}else{
			x = 100
		}
		or.width = x
	}

}
