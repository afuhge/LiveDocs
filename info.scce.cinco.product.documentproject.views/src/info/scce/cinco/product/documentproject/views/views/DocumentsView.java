package info.scce.cinco.product.documentproject.views.views;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.resource.ImageDescriptor;

import com.google.common.collect.Sets;

import info.scce.cinco.product.documentproject.views.ResourceChangeListener.ListenerEvents;
import info.scce.cinco.product.documentproject.views.pages.DocumentsPage;
import info.scce.cinco.product.documentproject.views.provider.DocumentsTreeProvider.ViewType;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

public class DocumentsView extends MainView<DocumentsPage> {
	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "info.scce.cinco.product.documentproject.views.views.Documents";
	private IAction createFileAction;
//	private IAction filterAbstractTypesAction;
	private IAction showFlatViewAction;
	private IAction showHierarchicalViewAction;
//	private IAction showInheritanceInfoAction;

	
	public DocumentsView() {
		Map<String, Set<ListenerEvents>> obsDefinition = new HashMap<>();
		obsDefinition.put("dependency", Sets.newHashSet(ListenerEvents.ADDED, ListenerEvents.REMOVED, ListenerEvents.CONTENT_CHANGE));
		
		this.obsDefinition = obsDefinition;
		this.genericParameterClass = DocumentsPage.class;
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
//
//				activePage.setShowInheritanceInfo(false);
//
//				activePage.getTreeViewer().removeFilter(
//						activePage.getFilterAbstractType());
//				activePage.setHideAbstractTypes(false);
//
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
