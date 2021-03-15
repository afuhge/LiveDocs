package info.scce.cinco.product.documentproject.generator.HTMLGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.Field
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.Panel
import info.scce.cinco.product.documentproject.template.template.TextField
import java.util.stream.Collectors
import java.util.ArrayList
import org.eclipse.emf.common.util.EList
import info.scce.cinco.product.documentproject.template.template.PanelRead
import graphmodel.Edge
import info.scce.cinco.product.documentproject.template.template.PanelWrite
import info.scce.cinco.product.documentproject.template.template.Write
import info.scce.cinco.product.documentproject.template.template.Read
import org.eclipse.emf.common.util.BasicEList
import info.scce.cinco.product.documentproject.template.template.StaticText

class PanelComponents_Html_Generator {
	
	protected extension Helper = new Helper
	
	
	def generate (info.scce.cinco.product.documentproject.dependency.dependency.Panel panel)'''
		<form [ngFormModel]="myPanel" (ngSubmit)="submit(myPanel);" *ngIf="panel != null && isEnabled()">
		
		    <div class="card «generatePanelColor(panel.tmplPanel)»" [attr.id]="'panel'+panel.id.toString()">
		        <div class="card-header text-white">{{panel.name}}</div>
		        <div [hidden]="!panel.panelOpen" class="card-body text-secondary active-info">
		        «generateFormGroups(panel.tmplPanel)»
		        «FOR dep:  (panel.tmplPanel).dependencys»  
		        	<panels-switch *ngIf="panel.«(dep.dependency as Dependency).escape.toFirstLower» != null && panel.«(dep.dependency as Dependency).escape.toFirstLower».start !=null" [dep]="panel.«(dep.dependency as Dependency).escape.toFirstLower»" [panel]="panel.«(dep.dependency as Dependency).escape.toFirstLower».start"></panels-switch>
		        «ENDFOR»      
		        <div class="row">
		            <small class="col text-right">*&nbsp;Required</small>
		            </div>
		        </div>
		        <div class="card-footer">
		       		<b [hidden]="panel.panelOpen" class="text-secondary">'{{panel.name}}' was submitted at {{panel.submitTime | date:"short"}}</b>
		            <div class="btn-group-sm btn-group " style="display:block; text-align: right;" role="group">
		                <«panel.escape.toFirstLower.replace("_","-")»log [logs]="panel.logs"></«panel.escape.toFirstLower.replace("_","-")»log>
		                <button [hidden] ='!doc.isOpen || !panel.panelOpen «isPanelRead(panel.tmplPanel)»'  style="float:none;" type="reset" class="btn btn-info btn-sm rounded-right rounded-left">Clear</button>
		                <button [hidden] ='!doc.isOpen || !panel.panelOpen «isPanelRead(panel.tmplPanel)»'  [disabled]="myPanel.invalid" type="submit" style="float:none;" class="rounded-left btn «generateButtonColor(panel.tmplPanel)» btn-sm">«generatePreIcon(panel.tmplPanel)»«generateButtonLabel(panel.tmplPanel)»«generatePostIcon(panel.tmplPanel)»</button>
		           		 <button [hidden] ="panel.panelOpen" (click)="switchPanelOpen()"  type="button" style="float:none;" class="rounded-left btn btn-secondary btn-sm">
		           		                    <i class="fas fa-fw fa-edit text-white"></i>Edit</button>
		            </div>
		        </div>
		    </div>
		</form>
		<form [ngFormModel]="myPanel" (ngSubmit)="submit(myPanel);" *ngIf="panel != null && !isEnabled() «IF accessRightsDefined(panel.tmplPanel)»&& true«ELSE»&& false«ENDIF»">
		
		    <div class="card «generatePanelColor(panel.tmplPanel)»" [attr.id]="'panel'+panel.id.toString()">
		        <div class="card-header text-white">{{panel.name}}</div>
		        <div class="card-footer">
		            <b [hidden]="panel.isSubmitted" class="text-danger"> <i class="fas mr-2 fa-spin fa-fw fa-spinner fa-lg"></i>Processing is outstanding.</b>
		            <b [hidden]="!panel.isSubmitted" class="text-secondary"> '{{panel.name}}' was submitted at {{panel.submitTime | date:"short"}}</b>
		            <div class="btn-group-sm btn-group" style="display:block; text-align: right;" role="group">
		                <«panel.escape.toFirstLower.replace("_","-")»log [logs]="panel.logs"></«panel.escape.toFirstLower.replace("_","-")»log>
		            </div>
		        </div>
		    </div>
		</form>
	'''
	
	def accessRightsDefined(Panel panel) {
		var accessRightsDefined = true
		if(!panel.incoming.isEmpty){
			accessRightsDefined = true
		}else{
			if(!noFieldAccessRights(panel)){
				accessRightsDefined = true
			}else{
				accessRightsDefined = false
			}
		}
		return accessRightsDefined
	}
	
	def isPanelRead(Panel panel) '''
	«IF panel.incoming.isEmpty»
		«IF panelHasReadField(panel)»
		«FOR role :  panel.fieldReads.roleRead BEFORE "||" SEPARATOR "||"»
		currentRole >= "«role.name.toFirstUpper»"
		«ENDFOR»
		«ENDIF»
	«ELSE»
		«IF !panel.incomingReads.isNullOrEmpty»
			«IF panelHasReadField(panel) && ! panelHasWriteField(panel)»
				«FOR role :  panel.fieldReads.roleRead BEFORE "||" SEPARATOR "||"»
				currentRole >= "«role.name.toFirstUpper»"
				«ENDFOR»
			«ENDIF»
			«IF noFieldAccessRights(panel)»
				«FOR role :  panel.incomingReads.roleRead BEFORE "||" SEPARATOR "||"»
				currentRole >= "«role.name.toFirstUpper»"
				«ENDFOR»
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
	
	def panelHasWriteField(Panel panel) {
		var hasWrite = false
		for(field : panel.fields)
		if(!field.incomingWrites.isNullOrEmpty){
			return true;
		}
		return hasWrite
	}
	
	def noFieldAccessRights(Panel panel) {
		var noAccessRight = true
		for(field : panel.fields){
			if(!field.incoming.isEmpty){
				 return false
			}
		}
		return noAccessRight;
	}
	
	
	
	def EList<Read> fieldReads(Panel panel){
		var allFieldsWithReadEdge = new BasicEList()
		for(field : panel.fields){
			if(!field.incomingReads.isNullOrEmpty){
				allFieldsWithReadEdge.addAll(field.incomingReads)
			}
		}
		return allFieldsWithReadEdge
	}
	
	def panelHasReadField(Panel panel) {
		var hasRead = false
		for(field : panel.fields)
		if(!field.incomingReads.isNullOrEmpty){
			return true;
		}
		return hasRead
	}
	
	def noFieldAccessRightsDefined(Panel panel) {
		var fieldWithRightsexist = false
		for(field : panel.fields){
			if(!field.incoming.isEmpty){
				fieldWithRightsexist = true
			}
		}
		return fieldWithRightsexist
	}	
	
	
	def getRoleWrite(EList<Write> writes) {
		var roles = new ArrayList()
		for(edge : writes){
			roles.add((edge.sourceElement as info.scce.cinco.product.documentproject.template.template.Role).role)
		}
		var allRoles = roles.stream().distinct().collect(Collectors.toList());
		return allRoles
	}
	
	def getRoleRead(EList<Read> reads) {
		var roles = new ArrayList()
		for(edge : reads){
			roles.add((edge.sourceElement as info.scce.cinco.product.documentproject.template.template.Role).role)
		}
		var allRoles = roles.stream().distinct().collect(Collectors.toList());
		return allRoles
	}
	
	def generatePostIcon(Panel panel) {
		var button = panel.buttons.get(0) 
		if(button.icon !== null){
			return generateIconTag(button.icon.postIcon.getName)
		}
	}
	
	def generateIconTag(String icon)'''
	«IF  icon != "None"»
	<i class="nav-icon fas fa-fw fa-«generateGlyphicon(icon)»"></i>
	«ENDIF»
	'''
	
	def generateGlyphicon(String icon) {
		return '''«icon.toLowerCase.escapeMissingIcon»'''
	}
	
	def escapeMissingIcon(String missingIcon) {
		switch (missingIcon) {
			case "apple" : return "apple-alt"
			case "alert": return "exclamation-triangle"
			case "chevronleft": return "chevron-left"
			case "chevronright": return "chevron-right"
			case "chevronup": return "chevron-up"
			case "chevrondown": return "chevron-down"
			case "arrowleft": return "arrow-left"
			case "arrowright": return "arrow-right"
			case "arrowup": return "arrow-up"
			case "arrowdown": return "arrow-down"
			case "bancircle": return "ban"
			case "blackboard": return "chalkboard"
			case "cd": return "compact-disc"
			case "dashboard": return "tachometer-alt"
			case "earphone": return "phone"
			case "education": return "school"
			case "euro": return "euro-sign"
			case "erase": return "eraser"
			case "eyeopen": return "eye"
			case "export": return "file-export"
			case "flash": return "bolt"
			case "folderclose": return "folder"
			case "folderopen": return "folder-open"
			case "glass": return "glass-martini"
			case "import": return "file-import"
			case "infosign": return "info-circle"
			case "login": return "sign-in-alt"
			case "logout": return "sign-out-alt"
			case "move": return "arrows-alt"
			case "off": return "power-off"
			case "ok": return "check"
			case "okcircle": return "check-circle"
			case "phone" : return "mobile-alt"
			case "pencil": return "pencil-alt"
			case "picture": return "image"
			case "questionsign": return "question-circle"
			case "refresh": return "sync"
			case "repeat": return "redo"
			case "scale": return "balance-scale"
			case "thumbsup": return "thumbs-up"
			case "time": return "clock"
			case "triangleup": return "caret-up"
			case "triangledown": return "caret-down"
			case "triangleleft": return "caret-left"
			case "triangleright": return "caret-right"
			case "usd": return "dollar-sign"
			case "zoomin": return "search-plus"
			case "zoomout" : return "search-minus"
			case "duplicate" : return "clone"
			case "equalizer" : return "wave-square"
			case "floppydisk" : return "compact-disc"
			case "floppysaved" : return "save"
			case "floppyremove" : return "trash-alt"
			case "open" : return "folder-open"
			case "pushpin" : return "thumbtack"
			case "remove" : return "times"
			case "removecircle" : return "times-circle"
			case "screenshot" : return "tablet-alt"
			case "send" : return "paper-plane"
			case "stats" : return "chart-pie"
			case "transfer" : return "exchange-alt"
			case "unchecked" : return "square"
			case "saved" : return "save"
			default : return missingIcon
		}
	}
	
	def generatePreIcon(Panel panel) {
		var button = panel.buttons.get(0)
		if(button.icon !== null){
			return generateIconTag(button.icon.preIcon.getName)
		}
	}
	
	def generateButtonColor(Panel panel) {
		var button = panel.buttons.get(0)
		switch (button.color.getName) {
			case "Default": return "btn-secondary"
			case "Red": return "btn-danger"
			case "Blue": return "btn-primary"
			case "Green": return "btn-success"
			case "Yellow": return "btn-warning"
			case "Lightblue": return "btn-info"
		}
	}
	
	def generateButtonLabel(Panel panel) {
		var button = panel.buttons.get(0)
		if(button.displayLabel.isNullOrEmpty){
			return "Submit"
		}
		else{
			return '''«button.displayLabel»'''
		}
	}
	
	def generatePanelColor(Panel panel) {
		switch (panel.color.getName) {
			case "Default": return "card-secondary"
			case "Red": return "card-danger"
			case "Blue": return "card-primary"
			case "Green": return "card-success"
			case "Yellow": return "card-warning"
			case "Lightblue": return "card-info"
			
		}
	}
	
	def generateFormGroups(Panel panel)'''
		«FOR inputfield : panel.nodes»
		«IF inputfield instanceof Field»
			«var field = inputfield as Field»
			«IF !isChoice(field) && !isCheckbox(field)»
				<div class="field form-group">
					<label [attr.for]="'«field.escape»'+ hashCode.toString()">«field.label.toFirstUpper»&nbsp;«generateAsterisk(field)»</label>
					<input type="«generateFieldType(field)»"  [disabled] ='!doc.isOpen «isFieldEnabled(panel, field)»' class="form-control «generateFieldColor(field)»" [attr.id]="'«field.escape»'+ hashCode.toString()" [attr.value]="myPanel.controls['«field.escape»'].value"
						«generatePlaceHolder(field)»
						ngControl="«field.escape»"
						[class.is-invalid]="myPanel.controls['«field.escape»'].invalid && myPanel.controls['«field.escape»'].touched"
						[class.is-valid]="!myPanel.controls['«field.escape»'].invalid">
						«generateHelpText(field)»
						  <div [hidden]="myPanel.controls['«field.escape»'].valid || myPanel.controls['«field.escape»'].pristine"
						       class="invalid-feedback">
						       «generateErrorText(field)»
						  </div>
					</div>
			«ENDIF»
			«IF isChoice(field)»
			   <div class="field form-group">
			           <label [attr.for]="'«field.escape»'+ hashCode.toString()">«field.label.toFirstUpper»&nbsp;*</label>
			              <select  class="form-control icon-caret" name="«field.label.toFirstLower»" ngControl="«field.escape»" [attr.type]="'dropdown'" [attr.id]="'«field.escape»'+ hashCode.toString()" [attr.value]="myPanel.controls['«field.escape»'].value" [disabled] ='!doc.isOpen «isFieldEnabled(panel, field)»'
			               [class.is-valid]="!myPanel.controls['«field.escape»'].invalid">
			                  <option  *ngFor="let p of «field.label.escapeLabel»Contents"  [value]="p" [attr.id]="p + hashCode.toString()">
			                      {{p}}
			                  </option>
			              </select>
			           </div>
			«ENDIF»
			«IF isCheckbox(field)»
			 <div class="field form-group">
			                <div class="form-check">
			                    <input type="checkbox" [disabled] ='!doc.isOpen «isFieldEnabled(panel, field)»' class="form-check-input" [attr.id]="'«field.escape»'+ hashCode.toString()" [attr.value]="myPanel.controls['«field.escape»'].value"
			                           ngControl="«field.escape»">
			                    <label class="form-check-label" [attr.for]="'«field.escape»'+ hashCode.toString()">«field.label.toFirstUpper»</label>
			                </div>
			            </div>
			«ENDIF»
		«ELSE»
		«IF inputfield instanceof StaticText»
		<p class="«generateTextColor(inputfield as StaticText)»">«(inputfield as StaticText).content»</p>
		«ENDIF»
		«ENDIF»
			«ENDFOR»
		'''

	def generateTextColor(StaticText text) {
		switch (text.color.getName) {
			case "Default": return ""
			case "Red": return "text-danger"
			case "Blue": return "text-primary"
			case "Green": return "text-success"
			case "Yellow": return "text-warning"
			case "Lightblue": return "text-info"
		}
	}
		

	def isFieldEnabled(Panel panel, Field field) '''
	«IF panel.incoming.isEmpty»
		«IF !field.incoming.isEmpty»
			«IF !field.incomingWrites.isNullOrEmpty»«ENDIF»
			«IF !field.incomingReads.isNullOrEmpty»
			«FOR role1 : field.incomingReads.roleRead BEFORE "||" SEPARATOR "||" »
			currentRole >= "«role1.name.toFirstUpper»"
			«ENDFOR»
			«ENDIF»
		«ELSE»
		 || true
		«ENDIF»
	«ELSE»
	«IF !panel.incomingWrites.isNullOrEmpty»
		«IF !field.incomingReads.isNullOrEmpty»
		«FOR role1 : field.incomingReads.roleRead BEFORE "||" SEPARATOR "||" »
		currentRole >= "«role1.name.toFirstUpper»"
		«ENDFOR»
		«ENDIF»
	«ENDIF»
	«IF !panel.incomingReads.isNullOrEmpty»
		«IF !field.incomingWrites.isNullOrEmpty»
		«ELSE»
		«IF field.incomingReads.isNullOrEmpty»
		«FOR role : panel.incomingReads.roleRead BEFORE "||" SEPARATOR "||" »
			currentRole >= "«role.name.toFirstUpper»"
		«ENDFOR»
		«ELSE»  «««panel read , field read : alles disabled
			«FOR role1 : field.incomingReads.roleRead BEFORE "||" SEPARATOR "||" »
			currentRole >= "«role1.name.toFirstUpper»"
			«ENDFOR»
		«ENDIF»
		«ENDIF»
	«ENDIF»
	«ENDIF»
	'''
	
	def generateAsterisk(Field field) {
		if(field.validation !== null){
			if(field.validation.required){
				return '''*'''
			}
		}
	}
	
	def generateFieldColor(Field field) {
		switch (field.color.getName) {
			case "Default": return ""
			case "Red": return "border border-danger"
			case "Blue": return "border border-primary"
			case "Green": return "border border-success"
			case "Yellow": return "border border-warning"
			case "Lightblue": return "border border-info"
		}
	}
	
	def generateHelpText(Field field) {
		if(field.additionalOptions !== null){
			if(!field.additionalOptions.helpText.isNullOrEmpty){
				return '''<small id="passwordHelpBlock" class="form-text text-muted">«field.additionalOptions.helpText»</small>'''
			}
		}
	}
	
	def isChoice(Field field) {
		if(field instanceof ChoiceField){
			return true
		}else{
			return false
		}
	}
	
	def isCheckbox(Field field) {
		if(field instanceof CheckBoxField){
			return true
		}
		return false
	}
	
	
	def generateFieldType(Field field) {
		switch (field) {
			NumberField : '''number'''
			TextField: '''text'''
			DateField : '''date'''
			CheckBoxField : '''checkbox'''
		}
	}
	
	def generatePlaceHolder(Field field) {
		if(field.additionalOptions !== null){
			if(!field.additionalOptions.emptyValue.isNullOrEmpty){
				'''placeholder="«field.additionalOptions.emptyValue»"'''
			}else{
				'''placeholder="Enter..."'''
			}
		}else{
				'''placeholder="Enter..."'''
			}
	}
	
	def generateErrorText(Field field) {
		if(field.validation !== null){
			if(!field.validation.errorText.isNullOrEmpty){
				'''«field.validation.errorText»'''
			}else{
				'''Please enter a «field.label.toFirstUpper»'''
			}
		}else{
				'''Please enter a «field.label.toFirstUpper»'''
			}
	}
	
}
