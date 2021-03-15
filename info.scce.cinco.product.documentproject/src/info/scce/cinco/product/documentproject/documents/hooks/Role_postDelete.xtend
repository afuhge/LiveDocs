package info.scce.cinco.product.documentproject.documents.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPreDeleteHook
import info.scce.cinco.product.documentproject.documents.documents.Role

class Role_postDelete extends CincoPreDeleteHook<Role>{
	
	override preDelete(Role role) {
		if(role.iconRef !== null){
			role.iconRef.delete
			role.iconRef = null
		}
	}
	
}