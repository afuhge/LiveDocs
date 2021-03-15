package info.scce.cinco.product.documentproject.generator.HTMLGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List
import info.scce.cinco.product.documentproject.dependency.dependency.XOR

class PanelSwitchComponent_HTML_Generator {
	
	protected extension Helper = new Helper
	
	def generate(List<Panel> panels, List<XOR> xors)'''
		<!--switch over all panels--->
		«FOR panel: panels»
			<«panel.escape.toFirstLower.replace("_","-")» class="panel" [attr.preCondition]="panel.preCondition"  *ngIf="instanceOf«panel.escape.toFirstUpper»" [dep]="dep" [panel]="panel"></«panel.escape.toFirstLower.replace("_","-")»>
				
		«ENDFOR»
		«FOR xor : xors»
		<xor-«xor.id.replace("_","-")»  class="panel" [attr.preCondition]="panel.preCondition"  *ngIf="instanceOfXOR_«xor.id.replace("_", "").replace("-","")»" [dep]="dep" [panel]="panel"></xor-«xor.id.replace("_","-")»>
		«ENDFOR»
		
		
		<!-- set next panel-->
		<panels-switch *ngIf="panel != null && panel.next != null" [dep]="dep" [panel]="panel.next"> </panels-switch>
		
	'''
}
