package info.scce.cinco.product.documentproject.views.pages;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.viewers.ViewerSorter;
import org.eclipse.swt.graphics.Image;
import org.eclipse.ui.IEditorPart;

import graphmodel.GraphModel;
import graphmodel.ModelElement;
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint;
import info.scce.cinco.product.documentproject.views.provider.ConstraintsTreeProvider;
import info.scce.cinco.product.documentproject.views.provider.MainTreeProvider.ModelType;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

public class ConstraintsPage extends MainPage{
	
	private ConstraintsTreeProvider data = new ConstraintsTreeProvider();

	private HashMap<String, Image> icons = new HashMap<>();

	private boolean showOnlyAllowedTypes = false;

	private ConstraintsLabelProvider labelProvider = new ConstraintsLabelProvider();
	private ConstraintsNameSorter nameSorter = new ConstraintsNameSorter();
	private ConstraintsModelTypeFilter modelTypeFilter = new ConstraintsModelTypeFilter();

	private ArrayList<ModelType> hideModelTypes = new ArrayList<ConstraintsTreeProvider.ModelType>();

	@Override
	public LabelProvider getDefaultLabelProvider() {
		return labelProvider;
	}

	@Override
	public ViewerSorter getDefaultSorter() {
		return nameSorter;
	}
	
	public boolean isShowOnlyAllowedTypes() {
		return showOnlyAllowedTypes;
	}

	public void setShowOnlyAllowedTypes(boolean showOnlyAllowedTypes) {
		this.showOnlyAllowedTypes = showOnlyAllowedTypes;
	}

	public ArrayList<ModelType> getHideModelTypes() {
		return hideModelTypes;
	}

	@Override
	public void reload() {
		storeTreeState();
		data.reset();
		treeViewer.setInput(parentViewPart.getViewSite());
		restoreTreeState();
	}
	
	public ConstraintsModelTypeFilter getModelTypeFilter() {
		return modelTypeFilter;
	}


	@Override
	public void openAndHighlight(Object obj) {
		obj = getTreeNodeData(obj);
		if (obj instanceof ModelElement) {
			ModelElement me = (ModelElement) obj;
			IEditorPart editorPart = openEditor(me.getRootElement());
			
			if (obj instanceof GraphModel) {
				openEditor((GraphModel) obj);
			}
			
//			if (me.getRootElement() instanceof Process) {
//				Process wrapper = data.getUtils().getProcessWrapperFromEditor(editorPart);
//				data.getUtils().highlightElement(wrapper, me.getId());
//			}
//			if (me.getRootElement() instanceof GUI) {
//				GUI wrapper = data.getUtils().getGuiWrapperFromEditor(editorPart);
//				data.getUtils().highlightElement(wrapper, me.getId());
//			}
		}
		else if (obj instanceof EObject) {
			openEditor((EObject) obj);
		}
		
	}

	@Override
	public ConstraintsTreeProvider getDataProvider() {
		return data;
	}
	
	@Override
	protected void loadIcons() {
		try {
			super.loadIcons();
			icons.put("ConstraintModel", new Image(MainUtils.getDisplay(), FileLocator
					.openStream(bundle,
							new Path("icons/constraint_icon.png"), true)));
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 
	 */
	private class ConstraintsLabelProvider extends LabelProvider {
		public String getText(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Constraint) {
				return data.getModelToResource().get(obj).getName();
			}
			return "";
		}
		
		public Image getImage(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Constraint)
				return icons.get("ConstraintModel");
			
			return null;
		}
	}
	
	private class ConstraintsModelTypeFilter extends ViewerFilter {

		@Override
		public boolean select(Viewer viewer, Object parentElement,
				Object element) {

			parentElement = getTreeNodeData(parentElement);
			element = getTreeNodeData(element);

			if (element instanceof EObject)
				if (hideModelTypes.contains(data
						.mapEObjectToType((EObject) element)))
					return false;
			return true;
		}
	}
	
	private class ConstraintsNameSorter extends ViewerSorter {

		@Override
		public int category(Object element) {
			if (element instanceof IFolder)
				return 1;
			if (element instanceof GraphModel)
				return 2;
//			if (element instanceof SIBLibrary)
//				return 3;
//			if (element instanceof Type)
//				return 4;
//			if (element instanceof SIB)
//				return 5;
//			if (element instanceof Plugins)
//				return 6;
			return 99;
		}

		@Override
		public int compare(Viewer viewer, Object e1, Object e2) {
			e1 = getTreeNodeData(e1);
			e2 = getTreeNodeData(e2);

			int cat1 = category(e1);
			int cat2 = category(e2);
			if (cat1 != cat2)
				return cat1 - cat2;

			if (e1 instanceof EObject && e2 instanceof EObject) {
				IResource res1 = data.getModelToResource().get(e1);
				IResource res2 = data.getModelToResource().get(e2);
				if (res1 != null && res2 != null)
					return res1.getName().toLowerCase()
							.compareTo(res2.getName().toLowerCase());
			}

			if (e1 instanceof IFolder && e2 instanceof IFolder) {
				IFolder folder1 = (IFolder) e1;
				IFolder folder2 = (IFolder) e2;
				return folder1.getName().toLowerCase()
						.compareTo(folder2.getName().toLowerCase());
			}
			
			if (e1 instanceof Constraint && e2 instanceof Constraint) {
				IResource res1 = data.getModelToResource().get(e1);
				IResource res2 = data.getModelToResource().get(e2);
				return res1.getName().toLowerCase()
						.compareTo(res2.getName().toLowerCase());
			}

			return super.compare(viewer, e1, e2);
		}

	}

}
