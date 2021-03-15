package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook
import graphmodel.Node
import info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.ImplicationPattern
import info.scce.cinco.product.documentproject.constraint.constraint.Panel
import org.eclipse.emf.common.util.EList

class FieldConstraint_PostCreate extends CincoPostCreateHook<FieldConstraint> {

	val OFFSET = 70
	val Y = 18

	override postCreate(FieldConstraint field) {
		if (field.container instanceof ImplicationPattern) {
			var pattern = field.container as ImplicationPattern
			pattern.width = pattern.nodes.layout
			if(pattern.nodes.size > 1){
				var previousElement = pattern.nodes.get(pattern.nodes.size-2)
				if(previousElement instanceof Panel){
					var pre = previousElement as Panel
					pre.newNext(field)
				}else if(previousElement instanceof FieldConstraint){
					var pre = previousElement as FieldConstraint
					pre.newNext(field)
				}
			}
		}
	}

	def layout(EList<Node> list) {
		var x = 10
		for (element : list) {
			element.moveTo(element.container, x, Y)
			x = x + element.width + OFFSET
		}
		return x
	}

}
