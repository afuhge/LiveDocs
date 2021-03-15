package info.scce.cinco.product.documentproject.generator.HTMLGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.Panel

class XORPanel_HTML_Generator  {
	protected extension Helper = new Helper()
	def generate (XOR xor)'''
	<!--Panel with buttons-->
	<form>
	
	    <div class="card card-secondary" [attr.id]="'panel'+panel.id.toString()">
	        <div class="card-header text-white">{{panel.name}}</div>
	        <div [hidden]="!panel.panelOpen" class="card-body text-secondary active-info">
	            <div class="btn-group-sm btn-group " style="display:block; text-align: center;" role="group">
	                <div class="row">
	                	«generateButtons(xor)»
	                </div>
	            </div>
	        </div>
	        <div class="card-footer">
	            <b [hidden]="panel.panelOpen" class="text-secondary">'{{panel.name}}' was submitted at {{panel.submitTime | date:"short"}}</b>
	            <div class="btn-group-sm btn-group " style="display:block; text-align: right;" role="group">
	                <button [hidden] ="panel.panelOpen" (click)="switchPanelOpen()"  type="button" style="float:none;" class="rounded-left btn btn-secondary btn-sm">
	                    <i class="fas fa-fw fa-edit text-white"></i>Edit</button>
	            </div>
	        </div>
	    </div>
	</form>
	'''
	
	def generateButtons(XOR xor) '''
	«FOR panel : xor.panels SEPARATOR '<b class="text-secondary pl-5 pr-5"> OR</b>'»
	<button type="button" (click)="addPanel«panel.escape.toFirstUpper»()"   class="btn «generateButtonColor(panel.tmplPanel)» btn-sm rounded-right rounded-left «generateTextColor(panel.tmplPanel)»">«panel.name»</button>
	«ENDFOR»
	'''
	
	def generateTextColor(Panel panel) {
		if(panel.color.getName != "Default"){
			return "text-white"
		}
	}
	
	def generateButtonColor(Panel panel) {
		switch (panel.color.getName) {
			case "Default": return "btn-secondary"
			case "Red": return "btn-danger"
			case "Blue": return "btn-primary"
			case "Green": return "btn-success"
			case "Yellow": return "btn-warning"
			case "Lightblue": return "btn-info"
			
		}
	}
	
}