package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPreDeleteHook
import info.scce.cinco.product.documentproject.constraint.constraint.Premise

class Premise_PreDelete extends CincoPreDeleteHook<Premise>{
	
	override preDelete(Premise pre) {
		if(!pre.conclusionSuccessors.isNullOrEmpty){
			pre.conclusionSuccessors.forEach[delete]
		}
	}
	
}