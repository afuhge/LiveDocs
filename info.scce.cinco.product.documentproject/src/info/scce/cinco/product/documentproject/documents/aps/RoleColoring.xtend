package info.scce.cinco.product.documentproject.documents.aps

import de.jabc.cinco.meta.core.ge.style.generator.runtime.appearance.StyleAppearanceProvider
import info.scce.cinco.product.documentproject.documents.documents.Role
import style.Color
import style.StyleFactory

class RoleColoring implements StyleAppearanceProvider<Role>{
	
	override getAppearance(Role role, String arg1) {
		var app = StyleFactory.eINSTANCE.createAppearance();
		if(role.isFirst){
			app.background = black
		}else if (role.isLast){
			app.background = grey
		}else {
			app.background = blue
		}
		
		return app
	}
	
	def boolean isLast(Role it){
		return outgoingTransitions.nullOrEmpty
	}
	
	def boolean isFirst(Role it){
		return incomingTransitions.isNullOrEmpty
	}
	
	
	
	/**
	 * Returns a blue style color
	 * 
	 * @return
	 */
	def Color blue() {
		var cl = StyleFactory.eINSTANCE.createColor();
		cl.setR(32);
		cl.setG(74);
		cl.setB(135);
		return cl;
	}

	/**
	 * Returns a black style color
	 * 
	 * @return
	 */
	def Color black() {
		var cl = StyleFactory.eINSTANCE.createColor();
		cl.setB(0);
		cl.setG(0);
		cl.setR(0);
		return cl;
	}

	/**
	 * Returns a white style color
	 * 
	 * @return
	 */
	def Color grey() {
		var cl = StyleFactory.eINSTANCE.createColor();
		cl.setB(133);
		cl.setG(138);
		cl.setR(136);
		return cl;
	}
	
	
}