package info.scce.cinco.product.documentproject.template.checks

import info.scce.cinco.product.documentproject.template.mcam.modules.checks.TemplateCheck
import info.scce.cinco.product.documentproject.template.template.Role
import info.scce.cinco.product.documentproject.template.template.Template
import java.util.ArrayList

class AccessRightsDuplicated extends TemplateCheck {

	override check(Template model) {
		for (role : model.roles) {
			checkDuplicatedWriteEdges(role)
			checkDuplicatedReadEdges(role)
			checkBothModelled(role)
		}
	}

	def checkBothModelled(Role role) {
		var readTarget = new ArrayList
		var writeTarget = new ArrayList

		for (edge : role.outgoingReads) {
			readTarget.add(edge.targetElement)
		}
		for (edge : role.outgoingWrites) {
			writeTarget.add(edge.targetElement)
		}

		var common = new ArrayList(readTarget)
		common.retainAll(writeTarget)
		if (!common.isNullOrEmpty) {
			addError(role, '''Write and Read-edges are defined both for '«role.role.name»'. Please delete one.''')
		}

	}

	def checkDuplicatedReadEdges(Role role) {
		var target = new ArrayList()
		for (read : role.outgoingReads) {
			if (!target.contains(read.targetElement)) {
				target.add(read.targetElement)
			} else {
				addError(role, '''Duplicated read-Edge of '«role.role.name»' modelled.''')
			}
		}
	}

	def checkDuplicatedWriteEdges(Role role) {
		var target = new ArrayList()
		for (read : role.outgoingWrites) {
			if (!target.contains(read.targetElement)) {
				target.add(read.targetElement)
			} else {
				addError(role, '''Duplicated write-Edge of '«role.role.name»' modelled.''')
			}
		}
	}

}
