package info.scce.cinco.product.documentproject.documents.hooks

import de.jabc.cinco.meta.runtime.action.CincoPostAttributeChangeHook
import info.scce.cinco.product.documentproject.documents.documents.Role
import org.eclipse.emf.ecore.EStructuralFeature

class Role_ValueChange extends CincoPostAttributeChangeHook<Role> {

	override canHandleChange(Role arg0, EStructuralFeature arg1) {
		true
	}

	override handleChange(Role role, EStructuralFeature arg1) {
		if (arg1.name == "manageUsers") {
			if (role.manageUsers) {
				var graphmodel = role.rootElement
				var x = role.x + role.width -5
				var y = role.y
				var icon = graphmodel.newUserIcon(x, y, 20, 20)
				role.iconRef = icon
			} else {
				if (role.iconRef !== null) {
					role.iconRef.delete
					role.iconRef = null
				}
			}

		}
	}

}
