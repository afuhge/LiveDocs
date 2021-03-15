package info.scce.cinco.product.documentproject.generator

import de.jabc.cinco.meta.core.utils.EclipseFileUtils
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.documents.documents.Role
import info.scce.cinco.product.documentproject.generator.DartGenerator.AddUserComponent_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.CreateDocumentComponent_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.DocumentsService_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.PageContentComponent_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.PanelComponent_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.PanelComponents_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.PanelLogComponents_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.PanelSwitchComponent_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.UserService_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.XORPanel_Dart_Generator
import info.scce.cinco.product.documentproject.generator.DataClassGenerator.DependencyClasses_Generator
import info.scce.cinco.product.documentproject.generator.DataClassGenerator.DocumentClasses_Generator
import info.scce.cinco.product.documentproject.generator.DataClassGenerator.PanelClasses_Generator
import info.scce.cinco.product.documentproject.generator.DataClassGenerator.PanelLogsClasses_Generator
import info.scce.cinco.product.documentproject.generator.DataClassGenerator.RoleClasses_Generator
import info.scce.cinco.product.documentproject.generator.DataClassGenerator.User_Generator
import info.scce.cinco.product.documentproject.generator.HTMLGenerator.PanelComponents_Html_Generator
import info.scce.cinco.product.documentproject.generator.HTMLGenerator.PanelSwitchComponent_HTML_Generator
import info.scce.cinco.product.documentproject.generator.HTMLGenerator.XORPanel_HTML_Generator
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.common.util.EList
import info.scce.cinco.product.documentproject.generator.DTD.XMLDTDFile_Generator
import info.scce.cinco.product.documentproject.generator.DTD.XMLValidationService_Generator
import info.scce.cinco.product.documentproject.generator.DTD.WebService_Generator
import info.scce.cinco.product.documentproject.generator.DartGenerator.DocComponent_dart
import info.scce.cinco.product.documentproject.generator.DartGenerator.DocumentTreeComponent_Dart
import info.scce.cinco.product.documentproject.generator.DartGenerator.ModelCheckingService_Generator

class Generator implements IGenerator<Documents>  {
	
	var IFolder mainFolder
	var IFolder src
	var IFolder lib
	var IFolder panel
	var IFolder createDocComponent
	var IFolder add_user_component
	var IFolder panelsSwitchComponent
	var IFolder panel_component
	var IFolder panellog_component
	var IFolder service
	var IFolder dtd
	var IFolder web
	var IFolder livedocsws
	var IFolder livedocsws_src
	var IFolder docComponent
	var IFolder documenttreecomponent
	var IFolder livedocs
	val thisBundle = "info.scce.cinco.product.documentproject"
	
	protected extension Helper = new Helper
	override void generate(Documents docs, IPath targetDir, IProgressMonitor monitor) {
		
		

		//make folders
		val IProject project = ProjectCreator.getProject(docs.eResource())
		if(project.getFolder("generated_webapp")!== null){
			project.getFolder("generated_webapp").delete(true, monitor)
		}
		mainFolder = project.getFolder("generated_webapp")
		copyStaticResources()
		
		web = mainFolder.getFolder("web")
		EclipseFileUtils.mkdirs(web, monitor)
		
		lib = mainFolder.getFolder("lib")
		EclipseFileUtils.mkdirs(lib, monitor)
		
		livedocsws = mainFolder.getFolder("livedocs-ws")
		EclipseFileUtils.mkdirs(livedocsws, monitor)
		livedocsws_src = livedocsws.getFolder("src")
		EclipseFileUtils.mkdirs(livedocsws_src, monitor)
		
		livedocs = livedocsws_src.getFolder("/main/java/de/livedocs")
		EclipseFileUtils.mkdirs(livedocs, monitor)
		
		src = lib.getFolder("src")
		EclipseFileUtils.mkdirs(src, monitor)
		
		add_user_component = src.getFolder("add_user_component")
		EclipseFileUtils.mkdirs(add_user_component, monitor)
		
		panel = src.getFolder("panel")
		EclipseFileUtils.mkdirs(panel, monitor)
		
		panelsSwitchComponent = src.getFolder("panels_switch_component")
		EclipseFileUtils.mkdirs(panelsSwitchComponent, monitor)
		
		createDocComponent = src.getFolder("create_document_component")
		EclipseFileUtils.mkdirs(createDocComponent, monitor)
		
		docComponent = src.getFolder("docs")
		EclipseFileUtils.mkdirs(docComponent, monitor)
		
		documenttreecomponent = src.getFolder("document_tree_component")
		EclipseFileUtils.mkdirs(documenttreecomponent, monitor)
		
		dtd = web.getFolder("dtd")
		EclipseFileUtils.mkdirs(dtd, monitor)
		
		
		service = src.getFolder("service")
		EclipseFileUtils.mkdirs(service, monitor)
		
		//generate create doc component
		generateCreateDocComponent(docs, monitor)
		
		generateDocComponent(docs,monitor)
		//generateDocTreeComponent(docs,monitor)
		
		//generate panel components
		generatePanelComponent(docs, monitor)
		
		//generate XOR Component
		generateXORComponent(docs, monitor)
		
		//generate all panel logs
		generateLogModalComponents(docs, monitor)

		//Generates all data classes
		generateDataClasses(docs)
		
		//generate main panel component
		generatePanel(docs)
		
		//generate panel switch component
		generatePanelSwitchComponent(docs)
		
		//generate user.dart
		generateUser(docs.roles)
		
		//generate add_user_component
		generateAddUserComponent(docs.roles)
		
		//generate pagecontent dart
		generatePageContentComponent(docs.roles)
		
		//generate services
		generateServices(docs)
		
		
		//generate DTD files
		generateDTDs(docs)
		
		//generate Webservice
		generateWebService(docs)
	}
	
	def generateDocTreeComponent(Documents docs, IProgressMonitor monitor) {
		val CharSequence generateDocTree= new DocumentTreeComponent_Dart().generate(docs)
		EclipseFileUtils.writeToFile(documenttreecomponent.getFile(("document_tree_component.dart")), generateDocTree)
	}
	
	def generateWebService(Documents docs) {
		val CharSequence generateWebService= new WebService_Generator().generate(docs)
		EclipseFileUtils.writeToFile(livedocs.getFile(("WebService.java")), generateWebService)
	}
	
	
	def generateDTDs(Documents docs) {
		for(doc : docs.documents){
			val CharSequence generateXMLDTD= new XMLDTDFile_Generator().generate(doc)
			EclipseFileUtils.writeToFile(dtd.getFile(('''«(doc.dependency as Dependency).name».xml''')), generateXMLDTD)
		}
	}
	
	
	def generatePageContentComponent(EList<Role> roles) {
		val CharSequence generatePageContent= new PageContentComponent_Dart_Generator().generate(roles)
			EclipseFileUtils.writeToFile(lib.getFile(("pagecontent_component.dart")), generatePageContent)
			
	}
	
	def generateAddUserComponent(EList<Role> roles) {
		val CharSequence generateAddUser= new AddUserComponent_Dart_Generator().generate(roles)
			EclipseFileUtils.writeToFile(add_user_component.getFile(("add_user_component.dart")), generateAddUser)
			EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/add_user_component.html", add_user_component)	
			EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/add_user_component.css", add_user_component)	
	}
	
	def generateUser(EList<Role> roles) {
		val CharSequence generateUser = new User_Generator().generate(roles)
			EclipseFileUtils.writeToFile(src.getFile(("user.dart")), generateUser)
	}
	
	def generateCreateDocComponent(Documents docs, IProgressMonitor monitor) {
		val CharSequence generateCreateDoc = new CreateDocumentComponent_Dart_Generator().generate(docs)
			EclipseFileUtils.writeToFile(createDocComponent.getFile(("create_document_component.dart")), generateCreateDoc)
			EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/create_document_component.html", createDocComponent)	
	
	}
	
	def generateDocComponent(Documents docs, IProgressMonitor monitor) {
		val CharSequence generateDoc = new DocComponent_dart().generate(docs)
			EclipseFileUtils.writeToFile(docComponent.getFile(("doc_component.dart")), generateDoc)
	
	}
	
	def generateServices(Documents docs) {
		val CharSequence generateUserService = new UserService_Dart_Generator().generate(docs.roles)
		EclipseFileUtils.writeToFile(service.getFile(("users_service.dart")), generateUserService)

		val CharSequence generateDocumentsService = new DocumentsService_Dart_Generator().generate(docs)
		EclipseFileUtils.writeToFile(service.getFile(("documents_service.dart")), generateDocumentsService)
		
		val CharSequence generateXMLValidationService = new XMLValidationService_Generator().generate(docs)
		EclipseFileUtils.writeToFile(service.getFile(("xmlvalidation_service.dart")), generateXMLValidationService)
		
		val CharSequence generateModelCheckingService = new ModelCheckingService_Generator().generate(docs)
		EclipseFileUtils.writeToFile(service.getFile(("modelchecking_service.dart")), generateModelCheckingService)

	}
	
	def generateLogModalComponents(Documents docs,  IProgressMonitor monitor) {
		for(doc : docs.documents){
			for(panel : doc.panels){
				panellog_component = src.getFolder('''«panel.escape.toFirstLower»Log_modal_component''')
				EclipseFileUtils.mkdirs(panellog_component, monitor)
				
				val CharSequence generatePanelLogComponents_Dart = new PanelLogComponents_Dart_Generator().generate(panel)
				EclipseFileUtils.writeToFile(panellog_component.getFile(('''«panel.escape.toFirstLower»'''+ "Log_modal_component.dart")), generatePanelLogComponents_Dart)
				
				EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/panelLog_modal_component.html", panellog_component)	
			}
		}
		
	}
	
	def generatePanelComponent(Documents docs, IProgressMonitor monitor) {
		//fo each document in documents model
		for(doc : docs.documents){
			//for all panels wich are included in dependency model
			for(panel : doc.panels){
				panel_component = src.getFolder('''«panel.escape.toFirstLower»_component''')
			EclipseFileUtils.mkdirs(panel_component, monitor)
			
			val CharSequence generatePanelComponents_Dart = new PanelComponents_Dart_Generator().generate(panel)
			EclipseFileUtils.writeToFile(panel_component.getFile(('''«panel.escape.toFirstLower»'''+ "_component.dart")), generatePanelComponents_Dart)
			
			val CharSequence generatePanelComponents_Html = new PanelComponents_Html_Generator().generate(panel)
			EclipseFileUtils.writeToFile(panel_component.getFile(('''«panel.escape.toFirstLower»'''+ "_component.html")), generatePanelComponents_Html)
			
			EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/panel_component.css", panel_component)	
			}
		}
	}
	
	def generateXORComponent(Documents docs, IProgressMonitor monitor) {
		for(doc : docs.documents){
			var dep = doc.dependency as Dependency
			for(xor : dep.XORs){
				panel_component = src.getFolder('''XOR«xor.id»_component''')
			EclipseFileUtils.mkdirs(panel_component, monitor)
			
			val CharSequence generateXORComponent_Dart = new XORPanel_Dart_Generator().generate(xor)
			EclipseFileUtils.writeToFile(panel_component.getFile(('''XOR«xor.id»'''+ "_component.dart")), generateXORComponent_Dart)
			
			val CharSequence generateXORComponent_HTML = new XORPanel_HTML_Generator().generate(xor)
			EclipseFileUtils.writeToFile(panel_component.getFile(('''XOR«xor.id»'''+ "_component.html")), generateXORComponent_HTML)
			
			EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/panel_component.css", panel_component)	
			
			}
		}
	}
	
	def generatePanelSwitchComponent(Documents docs) {
		val CharSequence generatePanelSwitchDart = new PanelSwitchComponent_Dart_Generator().generate(docs.panels, docs.XORs)
		EclipseFileUtils.writeToFile(panelsSwitchComponent.getFile(("panels_switch_component.dart")),
			generatePanelSwitchDart)

		val CharSequence generatePanelSwitchHtml = new PanelSwitchComponent_HTML_Generator().generate(docs.panels, docs.XORs)
		EclipseFileUtils.writeToFile(panelsSwitchComponent.getFile(("panels_switch_component.html")),
			generatePanelSwitchHtml)
	}

	def generatePanel(Documents docs) {
		val CharSequence generatePanelDart = new PanelComponent_Dart_Generator().generate(docs.panels, docs.XORs)
		EclipseFileUtils.writeToFile(panel.getFile(("panel_component.dart")), generatePanelDart)
	}

	def copyStaticResources() {
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/web/", mainFolder)	
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/lib/", mainFolder)	
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/pubspec.yaml", mainFolder)	
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/livedocs-ws", mainFolder)	
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/m3c", mainFolder)	
	}
	
	def generateDataClasses(Documents docs) {
		val CharSequence generateRoles = new RoleClasses_Generator().generate(docs)
		EclipseFileUtils.writeToFile(lib.getFile(("role_classes.dart")), generateRoles)
		val CharSequence generateDeps = new DependencyClasses_Generator().generate(docs)
		EclipseFileUtils.writeToFile(lib.getFile(("dependency_classes.dart")), generateDeps)
		val CharSequence generateDocs = new DocumentClasses_Generator().generate(docs)
		EclipseFileUtils.writeToFile(lib.getFile(("document_classes.dart")), generateDocs)
		val CharSequence generatePanels = new PanelClasses_Generator().generate(docs.panels, docs.XORs)
		EclipseFileUtils.writeToFile(lib.getFile(("panel_classes.dart")), generatePanels)
		val CharSequence generatePanelsLogs = new PanelLogsClasses_Generator().generate(docs.panels)
		EclipseFileUtils.writeToFile(lib.getFile(("panel_logs_classes.dart")), generatePanelsLogs)
		
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/notification_service.dart", service)
		EclipseFileUtils.copyFromBundleToDirectory(thisBundle, "resources/other/panel_component.html", panel)
		
			
	}
}

