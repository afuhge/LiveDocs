package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostDeleteHook
import info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.ImplicationPattern

class FieldConstraint_PostDelete extends CincoPostDeleteHook<FieldConstraint> {
	val OFFSET = 50
	val Y = 18

	override getPostDeleteFunction(FieldConstraint field) {
		if (field.container instanceof ImplicationPattern) {
			val pattern = field.container as ImplicationPattern
			return [pattern.layout]
		}
	}

	def layout(ImplicationPattern pattern) {
		var x = 10
		if(!pattern.nodes.empty){
			for (element : pattern.nodes) {
				element.moveTo(element.container, x, Y)
				x = x + element.width + OFFSET
			}
		}else{
			x = 100
		}
		pattern.width = x
	}
}
