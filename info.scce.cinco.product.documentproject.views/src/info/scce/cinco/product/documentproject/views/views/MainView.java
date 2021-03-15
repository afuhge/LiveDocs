package info.scce.cinco.product.documentproject.views.views;


import info.scce.cinco.product.documentproject.views.ResourceChangeListener;
import info.scce.cinco.product.documentproject.views.ResourceChangeListener.ListenerEvents;
import info.scce.cinco.product.documentproject.views.pages.MainPage;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.ViewPart;
import org.osgi.framework.Bundle;
import org.osgi.framework.FrameworkUtil;


@SuppressWarnings("restriction")
public abstract class MainView<T extends MainPage> extends ViewPart implements IPartListener2{
	protected Class<T> genericParameterClass;
	protected Map<String, Set<ListenerEvents>> obsDefinition;

	private Bundle bundle = FrameworkUtil.getBundle(this.getClass());
	private Composite parent;

	protected T activePage;
	protected TreeViewer viewer;
	protected IFile activeFile;

	private HashMap<String, T> pageMap = new HashMap<>();

	protected IAction doubleClickAction;
	protected IAction expandAllAction;
	protected IAction collapseAllAction;
	protected IAction linkWithEditorAction;
	protected IAction reloadAction;
	protected IAction openModelAction;

	protected Image iconRefresh;
	protected Image iconCreateFile;
	protected Image iconCollapseAll;
	protected Image iconExpandAll;
	protected Image iconLinkWithEditor;

	private ResourceChangeListener resourceChangeListener;

	public IFile getActiveFile() {
		return activeFile;
	}

	public T getActivePage() {
		return activePage;
	}

	public HashMap<String, T> getPageMap() {
		return pageMap;
	}
	
	private T createPage(Class<T> clazz, Composite c, ViewPart vp,
			IProject project) throws InstantiationException,
			IllegalAccessException, IOException {
		T page = clazz.newInstance();
		page.initPage(c, vp, project);
		return page;
	}

	/**
	 * This is a callback that will allow us to create the viewer and initialize
	 * it.
	 */
	public void createPartControl(Composite parent) {
		this.parent = parent;
		this.parent.setLayout(new GridLayout(1, true));
		this.parent.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
				.addPartListener(this);

		resourceChangeListener = new ResourceChangeListener(this, obsDefinition);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(
				resourceChangeListener);

		try {
			loadIcons();
		} catch (IOException e) {
			e.printStackTrace();
		}

		makeActions();
		contributeToActionBars();

//		for (IEditorReference editor : PlatformUI.getWorkbench()
//				.getActiveWorkbenchWindow().getActivePage()
//				.getEditorReferences()) {
			loadPageByEditor(PlatformUI.getWorkbench()
					.getActiveWorkbenchWindow().getActivePage().getActiveEditor());
//		}
	}

	private void initControls() {
		viewer = activePage.getTreeViewer();

		// Create the help context id for the viewer's control
		PlatformUI.getWorkbench().getHelpSystem()
				.setHelp(viewer.getControl(), "libcompview.viewer");

		hookContextMenu();
		hookDoubleClickAction();
	}

	protected void hookContextMenu() {
		MenuManager menuMgr = new MenuManager("#PopupMenu");
		menuMgr.setRemoveAllWhenShown(true);
		menuMgr.addMenuListener(new IMenuListener() {
			public void menuAboutToShow(IMenuManager manager) {
				fillContextMenu(manager);
			}
		});
		Menu menu = menuMgr.createContextMenu(viewer.getControl());
		viewer.getControl().setMenu(menu);
		getSite().registerContextMenu(menuMgr, viewer);
	}

	protected void loadIcons() throws IOException {
		iconRefresh = new Image(MainUtils.getDisplay(),
				FileLocator.openStream(bundle, new Path("icons/refresh.gif"),
						true));

		iconCreateFile = new Image(MainUtils.getDisplay(),
				FileLocator.openStream(bundle,
						new Path("icons/create_file.gif"), true));

		iconCollapseAll = new Image(MainUtils.getDisplay(),
				FileLocator.openStream(bundle,
						new Path("icons/collapseall.png"), true));

		iconExpandAll = new Image(MainUtils.getDisplay(),
				FileLocator.openStream(bundle, new Path("icons/expandall.gif"),
						true));
		
		iconLinkWithEditor = PlatformUI.getWorkbench().getSharedImages()
				.getImage(ISharedImages.IMG_ELCL_SYNCED);
	}

	abstract protected void fillLocalPullDown(IMenuManager manager);

	abstract protected void fillContextMenu(IMenuManager manager);

	abstract protected void fillLocalToolBar(IToolBarManager manager);

	protected void makeActions() {
		/*
		 * ------------------------------------------
		 */
		reloadAction = new Action() {
			public void run() {
				if (activePage != null)
					activePage.reload();
				refreshView();
			}
		};
		reloadAction.setText("Reload");
		reloadAction.setToolTipText("Reload");
		reloadAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconRefresh));
		
		/*
		 * ------------------------------------------
		 */
		linkWithEditorAction = new Action() {
			public void run() {
				if (activePage != null)
					activePage.selectTreeItem(getActiveFile());
			}
		};
		linkWithEditorAction.setText("Link with editor");
		linkWithEditorAction.setToolTipText("Link with editor");
		linkWithEditorAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconLinkWithEditor));

		/*
		 * ------------------------------------------
		 */
		openModelAction = new Action() {
			public void run() {
				ISelection selection = viewer.getSelection();
				Object obj = ((IStructuredSelection) selection)
						.getFirstElement();
				activePage.openAndHighlight(obj);
			}
		};
		openModelAction.setText("open model");
		openModelAction.setToolTipText("open model");

		/*
		 * ------------------------------------------
		 */
		doubleClickAction = new Action() {
			public void run() {
				ISelection selection = viewer.getSelection();
				Object obj = ((IStructuredSelection) selection)
						.getFirstElement();
				activePage.toggleExpand(obj);
				activePage.storeTreeState();
			}
		};

		/*
		 * ------------------------------------------
		 */
		expandAllAction = new Action() {
			public void run() {
				if (activePage != null) {
					activePage.getTreeViewer().expandAll();
					activePage.storeTreeState();
				}
			}
		};
		expandAllAction.setText("Expand all");
		expandAllAction.setToolTipText("Expand all");
		expandAllAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconExpandAll));

		/*
		 * ------------------------------------------
		 */
		collapseAllAction = new Action() {
			public void run() {
				if (activePage != null) {
					activePage.getTreeViewer().collapseAll();
					activePage.storeTreeState();
				}
			}
		};
		collapseAllAction.setText("Collapse all");
		collapseAllAction.setToolTipText("Collapse all");
		collapseAllAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconCollapseAll));
	}

	abstract protected void reloadViewState();

	protected void setActivePage(T activePage) {
		this.activePage = activePage;
	}

	protected void contributeToActionBars() {
		IActionBars bars = getViewSite().getActionBars();
		fillLocalPullDown(bars.getMenuManager());
		fillLocalToolBar(bars.getToolBarManager());
	}

	protected void hookDoubleClickAction() {
		activePage.getTreeViewer().addDoubleClickListener(
				new IDoubleClickListener() {
					public void doubleClick(DoubleClickEvent event) {
						doubleClickAction.run();
					}
				});
	}

	/**
	 * Passing the focus request to the viewer's control.
	 */
	public void setFocus() {
		// viewer.getControl().setFocus();
	}

	public void refreshView() {
		if (!parent.isDisposed()) {
			parent.layout(true, true);
			parent.redraw();
			parent.update();
		}
	}

	protected void editorChanged() {
		refreshView();
	}

	protected void activePageChanged() {
		reloadViewState();
	}

	/**
	 * Part Listener Methods
	 */
	@Override
	public void partActivated(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName() + "Part active: "
//				+ partRef.getTitle());
	}

	@Override
	public void partBroughtToTop(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName() + "Part to top: "
//				+ partRef.getTitle());
	}

	@Override
	public void partClosed(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName() + "Part closed: "
//				+ partRef.getTitle());
	}

	@Override
	public void partDeactivated(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName()
//				+ "Part deactivated: " + partRef.getTitle());
	}

	@Override
	public void partOpened(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName() + "Part opened: "
//				+ partRef.getTitle());
	}

	@Override
	public void partHidden(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName() + "Part hidden: "
//				+ partRef.getTitle());
	}

	@Override
	public void partVisible(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName() + "Part visible: "
//				+ partRef.getTitle());
		if (partRef instanceof EditorReference) {
			loadPageByEditor(((EditorReference) partRef).getEditor(true));
		}
		
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
//		System.out.println(this.getClass().getSimpleName()
//				+ "Part input changed: " + partRef.getTitle());
	}

	public void loadPageByEditor(IEditorPart editor) {
		if (editor == null) return;
		
		IFile file = (IFile) editor.getEditorInput()
				.getAdapter(IFile.class);
		
		if (file == null) {
			System.err.println("[MainView] WARN: Failed to load editor page. "
					+ "Input file is null for: " + editor);
			return;
		}
		
		activeFile = file;
		

		if (parent.isDisposed())
			return;

		if (activePage == null
				|| !file.getProject().getName()
						.equals(activePage.getProject().getName())) {

			for (Control child : parent.getChildren()) {
				child.setVisible(false);
				if (child.getLayoutData() instanceof GridData)
					((GridData) child.getLayoutData()).exclude = true;
			}

			if (!pageMap.keySet().contains(file.getProject().getName())) {
				try {
					T newPage = createPage(genericParameterClass, parent,
							this, file.getProject());
					pageMap.put(file.getProject().getName(), newPage);
				} catch (InstantiationException e) {
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

			setActivePage(pageMap.get(file.getProject().getName()));
//				reloadAction.run();
			activePage.getFrameComposite().setVisible(true);
			((GridData) activePage.getFrameComposite().getLayoutData()).exclude = false;

			initControls();
			activePageChanged();
		}
		editorChanged();
	}
	
	@Override
	public void dispose() {
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
		.removePartListener(this);

		ResourcesPlugin.getWorkspace().removeResourceChangeListener(
		resourceChangeListener);
		
		super.dispose();
	}

}
