package info.scce.cinco.product.documentproject.wizard;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.ecore.EPackage.Registry;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.WorkbenchException;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension;
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint;
import info.scce.cinco.product.documentproject.constraint.constraint.ConstraintPackage;
import info.scce.cinco.product.documentproject.constraint.factory.ConstraintFactory;
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency;
import info.scce.cinco.product.documentproject.dependency.dependency.DependencyPackage;
import info.scce.cinco.product.documentproject.dependency.factory.DependencyFactory;
import info.scce.cinco.product.documentproject.documents.documents.Documents;
import info.scce.cinco.product.documentproject.documents.documents.DocumentsPackage;
import info.scce.cinco.product.documentproject.documents.factory.DocumentsFactory;
import info.scce.cinco.product.documentproject.template.factory.TemplateFactory;
import info.scce.cinco.product.documentproject.template.template.Template;
import info.scce.cinco.product.documentproject.template.template.TemplatePackage;


public class DocumentWizard extends Wizard implements IWorkbenchWizard{
	
	CreateNewProjectPage newProjectPage = new CreateNewProjectPage("newProjectPage");
	WorkbenchExtension wExtension= new  WorkbenchExtension();
	@Override
	public void addPages() {		
		addPage(newProjectPage);
		super.addPages();
	}
		
	@Override
	public boolean canFinish() {
		return newProjectPage.isPageComplete();
	}
	private List<String> getNatures() {
		List<String> natures = new ArrayList<String>();
		natures.add("org.eclipse.xtext.ui.shared.xtextNature");
		return natures;
	}

	
	/**
	 * Diese Methode stellt dem Nutzer über den Editor-gebundenen "Workspace" Template-Dateien zur Verfügugung 
	 * und öffnet die Editor-View.
	 */
	@Override
	public boolean performFinish() {
				
		String projectName = newProjectPage.getProjectName();
		
		// Abspeichern der (I)Projekt-Referenz, um sie später wiederzuverwenden (den Speicherpfad auslesen).
		IProject project = ProjectCreator.createPlainProject(
				projectName, 
				getNatures(), 
				new NullProgressMonitor(),
				Collections.emptyList(),
				true
				);		
		
        
        // Ein Template-Workflow-Projekt anlegen; die Editor-View öffnen;
		DocumentsFactory eFactory = (DocumentsFactory) Registry.INSTANCE.getEFactory(DocumentsPackage.eNS_URI);
		IPath path = project.getFullPath();
		Documents roles = (Documents) eFactory.createDocuments(path.toString(), "Documents");
		wExtension.openEditor(roles);
        
        DependencyFactory dFact = (DependencyFactory) Registry.INSTANCE.getEFactory(DependencyPackage.eNS_URI);
        Dependency dep = (Dependency) dFact.createDependency(path.toString(), "Dependency");
        
        TemplateFactory tFact = (TemplateFactory) Registry.INSTANCE.getEFactory(TemplatePackage.eNS_URI);
        Template temp = (Template) tFact.createTemplate(path.toString(), "Template");
        
        ConstraintFactory cFact = (ConstraintFactory) Registry.INSTANCE.getEFactory(ConstraintPackage.eNS_URI);
        Constraint ctl = (Constraint) cFact.createConstraint(path.toString(), "Constraint");
        
        try {
			project.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor());
		} catch (CoreException e1) {
			e1.printStackTrace();
		}
		
		IWorkbench workbench = PlatformUI.getWorkbench();
		try {
			workbench.showPerspective("info.scce.cinco.product.documentproject.documentprojectperspective", workbench.getActiveWorkbenchWindow());
		} catch (WorkbenchException e) {
			e.printStackTrace();
		}

		return true;	
		
	}
	
	
	
	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		setWindowTitle("New Document Project");
	}

	private class CreateNewProjectPage extends WizardPage {
		
		private Text txtProjectName;		
		
		protected CreateNewProjectPage(String pageName) {
			super(pageName);
			setTitle("New Document Project");
			setDescription("Initialize a Document Project and immediately start modeling.");
			setPageComplete(false);
		}

		@Override
		public void createControl(Composite parent) {
			Composite comp = new Composite(parent, SWT.NONE); 
			comp.setLayout(new GridLayout(2, false));
			
			Label lblProjectName = new Label(comp, SWT.NONE);
			lblProjectName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
			lblProjectName.setText("&Project Name");
			
			txtProjectName = new Text(comp, SWT.BORDER);
			txtProjectName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
			
			//Anpassung: Tips
			Label tip1 = new Label(comp, SWT.NONE);
			tip1.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 2, 1));
			tip1.setText("&Tip 1: This dialog automatically creates a .documents-file, a .template-file,  a constraint-file and a .dependency-file.");
			
			addListeners();
			initContents();
			setControl(comp);
			
		}

		private void initContents() {			
			txtProjectName.setText("MyDocument");			
			dialogChanged();
		}
		
		private void addListeners() {			
			KeyListener pageCompleteValidationListener = new KeyListener() {
				
				@Override
				public void keyReleased(KeyEvent e) {
					dialogChanged();
				}
				
				@Override
				public void keyPressed(KeyEvent e) {
					// do nothing. wait for release.
				}
			};			
			
			txtProjectName.addKeyListener(pageCompleteValidationListener);
		}
		

		private void updateStatus(String msg) {
			setErrorMessage(msg);
			if (getContainer().getCurrentPage() != null) {
				getWizard().getContainer().updateMessage();
				getWizard().getContainer().updateButtons();
			}
			setPageComplete(getErrorMessage() == null);
		}
		
		private void dialogChanged() {
			String projectNameError = validateProjectName(txtProjectName.getText());			
			if (projectNameError != null)
				updateStatus(projectNameError);			
			else updateStatus(null);
		}
		
		public String getProjectName() {
			return txtProjectName.getText();
		}
		
		private String validateProjectName(String projectName) {
			if (projectName.isEmpty())
				return "Enter Document Project name";
			IProject[] projects = ResourcesPlugin.getWorkspace().getRoot()
					.getProjects();
			for (IProject p : projects) {
				if (p.getName().equals(projectName))
					return "Project: " + projectName + " already exists";
			}
			if (projectName.matches(".*[:/\\\\\"&<>\\?#,;].*")) {
				return "The project name contains illegal characters (:/\"&<>?#,;)";
			}
			return null;
		}
		
		
	}


}
