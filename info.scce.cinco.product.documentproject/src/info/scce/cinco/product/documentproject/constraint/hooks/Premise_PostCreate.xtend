package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook
import info.scce.cinco.product.documentproject.constraint.constraint.Premise

class Premise_PostCreate extends CincoPostCreateHook<Premise>{
	
	override postCreate(Premise premise) {
		var constraint = premise.container
		var newConclusion = constraint.newConclusion((premise.x + premise.width+70), premise.y, 250,70)
		premise.newImplication(newConclusion)
	}
	
}