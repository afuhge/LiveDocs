package info.scce.cinco.product.documentproject.views.views;

import java.util.ArrayList;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.part.*;
import com.google.common.collect.Sets;
import info.scce.cinco.product.documentproject.views.ResourceChangeListener.ListenerEvents;
import info.scce.cinco.product.documentproject.views.pages.RolesPage;
import info.scce.cinco.product.documentproject.views.provider.RolesTreeProvider.ViewType;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

import org.eclipse.jface.viewers.*;
import org.eclipse.swt.graphics.Image;
import org.eclipse.jface.action.*;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.*;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.SWT;
import org.eclipse.core.runtime.IAdaptable;
import javax.inject.Inject;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * This sample class demonstrates how to plug-in a new
 * workbench view. The view shows data obtained from the
 * model. The sample creates a dummy model on the fly,
 * but a real implementation would connect to the model
 * available either in this or another plug-in (e.g. the workspace).
 * The view is connected to the model using a content provider.
 * <p>
 * The view uses a label provider to define how model
 * objects should be presented in the view. Each
 * view can present the same model objects using
 * different labels and icons, if needed. Alternatively,
 * a single label provider can be shared between views
 * in order to ensure that objects of the same type are
 * presented in the same way everywhere.
 * <p>
 */

public class RolesView extends MainView<RolesPage> {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "info.scce.cinco.product.documentproject.views.views.Roles";
//	private IAction filterAbstractTypesAction;
	private IAction showFlatViewAction;
	private IAction showHierarchicalViewAction;
//	private IAction showInheritanceInfoAction;
	
	private IAction createFileAction;
	
	public RolesView() {
		Map<String, Set<ListenerEvents>> obsDefinition = new HashMap<>();
		obsDefinition.put("documents", Sets.newHashSet(ListenerEvents.ADDED, ListenerEvents.REMOVED, ListenerEvents.CONTENT_CHANGE));
		
		this.obsDefinition = obsDefinition;
		this.genericParameterClass = RolesPage.class;
	}
	
	@Override
	protected void fillLocalPullDown(IMenuManager manager) {
		IMenuManager filterSubmenu = new MenuManager("Filters");
//		filterSubmenu.add(filterAbstractTypesAction);

		IMenuManager viewSubmenu = new MenuManager("Display Mode");
		viewSubmenu.add(showFlatViewAction);
		viewSubmenu.add(showHierarchicalViewAction);

		manager.add(filterSubmenu);
		manager.add(viewSubmenu);

		manager.add(new Separator());

//		manager.add(showInheritanceInfoAction);
	}

	@Override
	protected void fillContextMenu(IMenuManager manager) {
		manager.add(openModelAction);		
	}

	@Override
	protected void fillLocalToolBar(IToolBarManager manager) {
		manager.add(reloadAction);
		manager.add(expandAllAction);
		manager.add(collapseAllAction);
		manager.add(linkWithEditorAction);
		manager.add(new Separator());
		
	}

	@Override
	protected void makeActions() {
		super.makeActions();
		
		createFileAction = new Action() {
			public void run() {
				// IWizard wizard =
				// LibCompUtils.getWizard("info.scce.dime.data.wizard.data");
				// if (wizard != null && wizard instanceof NewDataDiagramWizard)
				// {
				//
				// System.out.println(wizard.getStartingPage());
				//
				// WizardDialog wd = new WizardDialog(LibCompUtils.getDisplay()
				// .getActiveShell(), wizard);
				// wd.setTitle(wizard.getWindowTitle());
				//
				// System.out.println(wd.getCurrentPage());
				//
				// System.out.println(wd);
				//
				// wd.open();
				// }

			}
		};
		createFileAction.setText("Create data model");
		createFileAction.setToolTipText("Create data model");
		createFileAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconCreateFile));

		/*
		 * ------------------------------------------
		 */
//		filterAbstractTypesAction = new Action() {
//			public void run() {
////				if (!activePage.isHideAbstractTypes()) {
////					activePage.getTreeViewer().addFilter(
////							activePage.getFilterAbstractType());
////					activePage.setHideAbstractTypes(true);
////				} else {
////					activePage.getTreeViewer().removeFilter(
////							activePage.getFilterAbstractType());
////					activePage.setHideAbstractTypes(false);
////				}
//				reloadViewState();
//			}
//		};
//		filterAbstractTypesAction.setText("filter abstract types");
//		filterAbstractTypesAction.setToolTipText("filter abstract types");
//		filterAbstractTypesAction.setChecked(false);

		/*
		 * ------------------------------------------
		 */
		showFlatViewAction = new Action() {
			public void run() {
//				activePage.getDataProvider().setActiveView(ViewType.FLAT);
//
//				activePage.setShowInheritanceInfo(true);
				activePage.getTreeViewer().setLabelProvider(
						activePage.getDefaultLabelProvider());

				MainUtils.runBusy(new Runnable() {
					public void run() {
						activePage.reload();
						reloadViewState();
					}
				});
			}
		};
		showFlatViewAction.setText("Flat");
		showFlatViewAction.setToolTipText("show flat view");
		showFlatViewAction.setChecked(true);

		/*
		 * ------------------------------------------
		 */
		showHierarchicalViewAction = new Action() {
			public void run() {
				activePage.getDataProvider().setActiveView(ViewType.HIERARCHY);

//				activePage.setShowInheritanceInfo(false);

//				activePage.getTreeViewer().removeFilter(
//						activePage.getFilterAbstractType());
//				activePage.setHideAbstractTypes(false);

				activePage.getTreeViewer().setLabelProvider(
						activePage.getDefaultLabelProvider());

				MainUtils.runBusy(new Runnable() {
					public void run() {
						activePage.reload();
						reloadViewState();
					}
				});
			}
		};
		showHierarchicalViewAction.setText("Hierarchical");
		showHierarchicalViewAction.setToolTipText("show hierarchical view");
		showHierarchicalViewAction.setChecked(false);

		/*
		 * ------------------------------------------
		 */
//		showInheritanceInfoAction = new Action() {
//			public void run() {
////				boolean state = activePage.isShowInheritanceInfo();
////				activePage.setShowInheritanceInfo(!state);
//				activePage.getTreeViewer().setLabelProvider(
//						activePage.getDefaultLabelProvider());
//
//				reloadViewState();
//			}
//		};
//		showInheritanceInfoAction.setText("show inheritance");
//		showInheritanceInfoAction
//				.setToolTipText("show inheritance information");
//		showInheritanceInfoAction.setChecked(true);

	}

	@Override
	protected void reloadViewState() {
		showFlatViewAction.setChecked(false);
		showHierarchicalViewAction.setChecked(false);
		switch (activePage.getDataProvider().getActiveView()) {
		case FLAT:
			showFlatViewAction.setChecked(true);
			break;
		case HIERARCHY:
			showHierarchicalViewAction.setChecked(true);
			break;
		default:
			break;
		}

		activePage.getTreeViewer().refresh();
	}

	
}
