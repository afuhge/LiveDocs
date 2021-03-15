package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import org.eclipse.emf.common.util.EList
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.generator.Helper

class NoEdgesofPanelInContainer extends DependencyCheck {
	static extension Helper =  new Helper()
	override check(Dependency dep) {
		checkAND(dep.ANDs)
		checkOR(dep.ORs)
		checkXOR(dep.XORs)
	}
	
	def checkXOR(EList<XOR> xors) {
		for(xor : xors){
			for(panel : xor.panels){
				if(!panel.outgoing.isNullOrEmpty){
					addWarning(panel, '''Panel '«panel.tmplPanel.name»' is not allowed to have outgoing edges.''')
				}
				if(!panel.incoming.isEmpty){
					addWarning(panel, '''Panel '«panel.tmplPanel.name»' is not allowed to have incoming edges.''')
				}
			}
		}
	}
	
	def checkOR(EList<OR> ors) {
		for(or : ors){
			for(panel : or.panels){
				if(!panel.outgoing.isNullOrEmpty){
					addWarning(panel, '''Panel '«panel.tmplPanel.name»' is not allowed to have outgoing edges.''')
				}
				if(!panel.incoming.isEmpty){
					addWarning(panel, '''Panel '«panel.tmplPanel.name»' is not allowed to have incoming edges.''')
				}
			}
		}
	}
	
	def checkAND(EList<AND> ands) {
		for(and : ands){
			for(panel : and.panels){
				if(!panel.outgoing.isNullOrEmpty){
					addWarning(panel, '''Panel '«panel.tmplPanel.name»' is not allowed to have outgoing edges.''')
				}
				if(!panel.incoming.isEmpty){
					addWarning(panel, '''Panel '«panel.tmplPanel.name»' is not allowed to have incoming edges.''')
				}
			}
		}
	}
	
}