package info.scce.cinco.product.documentproject.views.pages;

import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.ViewerSorter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.swt.graphics.Image;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.PlatformUI;

import graphmodel.GraphModel;
import graphmodel.ModelElement;
import info.scce.cinco.product.documentproject.views.provider.MainTreeProvider.ModelType;
import info.scce.cinco.product.documentproject.documents.documents.Documents;
import info.scce.cinco.product.documentproject.documents.documents.Role;
import info.scce.cinco.product.documentproject.views.provider.RolesTreeProvider;
import info.scce.cinco.product.documentproject.views.provider.TreeProvider;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

public class RolesPage extends MainPage{

	private RolesTreeProvider data = new RolesTreeProvider();

	private HashMap<String, Image> icons = new HashMap<>();

	private boolean showOnlyAllowedTypes = false;

	private RolesLabelProvider labelProvider = new RolesLabelProvider();
	private RolesNameSorter nameSorter = new RolesNameSorter();
	private RolesModelTypeFilter modelTypeFilter = new RolesModelTypeFilter();

	private ArrayList<ModelType> hideModelTypes = new ArrayList<RolesTreeProvider.ModelType>();

	/*
	 * Getter / Setter
	 */
	@Override
	public RolesTreeProvider getDataProvider() {
		return data;
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
	public LabelProvider getDefaultLabelProvider() {
		return labelProvider;
	}

	@Override
	public ViewerSorter getDefaultSorter() {
		return nameSorter;
	}

	public RolesModelTypeFilter getModelTypeFilter() {
		return modelTypeFilter;
	}
	
	protected void loadIcons() {
		try {
			icons.put(
					"DocumentsModel",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/documents_icon.png"), true)));
			icons.put(
					"Role",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/role.png"), true)));
		}catch (IOException e) {
			e.printStackTrace();
		}
		
	}

	@Override
	public void openAndHighlight(Object obj) {
		obj = getTreeNodeData(obj);
		if (obj instanceof ModelElement) {
			ModelElement me = (ModelElement) obj;
			IEditorPart editorPart = openEditor(me.getRootElement());
			
//			if (me.getRootElement() instanceof Process) {
//				Process wrapper = data.getUtils().getProcessWrapperFromEditor(editorPart);
//				data.getUtils().highlightElement(wrapper, me.getId());
//			}
//			if (me.getRootElement() instanceof GUI) {
//				GUI wrapper = data.getUtils().getGuiWrapperFromEditor(editorPart);
//				data.getUtils().highlightElement(wrapper, me.getId());
//			}
		}
		if (obj instanceof GraphModel) {
			openEditor((GraphModel) obj);
		}
	}

	@Override
	public void reload() {
		storeTreeState();
		data.reset();
		treeViewer.setInput(parentViewPart.getViewSite());
		restoreTreeState();
	}

	public void calculateModelTypesToHide(IResource res) {
		hideModelTypes.clear();

		EObject activeModel = data.getEObjectForResource(res);
		ModelType modelType = data.mapEObjectToType(activeModel);
		List<ModelType> allowedTypes = data.getAllowedModels().get(modelType);

		for (ModelType type : ModelType.values()) {
			if (allowedTypes == null || !allowedTypes.contains(type))
				hideModelTypes.add(type);
		}
	}
	
	/**
	 * 
	 */
	private class RolesLabelProvider extends LabelProvider {
		public String getText(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Documents) {
				return data.getModelToResource().get(obj).getName();
			} else if (obj instanceof Role) {
				String label = ((Role) obj).getName();
				return label;
			}
			return "unknown";
		}
		
		public Image getImage(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Documents)
				return icons.get("DocumentsModel");
			if (obj instanceof Role)
				return icons.get("Role");
			
			return null;
		}
	}

	private class RolesModelTypeFilter extends ViewerFilter {

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
	
	private class RolesNameSorter extends ViewerSorter {

		@Override
		public int category(Object element) {
			if (element instanceof IFolder)
				return 1;
			if (element instanceof GraphModel)
				return 2;
			if(element instanceof Role) {
				return 3;
			}
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
			
			if (e1 instanceof Documents && e2 instanceof Documents) {
				IResource res1 = data.getModelToResource().get(e1);
				IResource res2 = data.getModelToResource().get(e2);
				return res1.getName().toLowerCase()
						.compareTo(res2.getName().toLowerCase());
			}

			if (e1 instanceof Role && e2 instanceof Role) {
				Role type1 = (Role) e1;
				Role type2 = (Role) e2;
				return type1.getName().toLowerCase()
						.compareTo(type2.getName().toLowerCase());
			}

			return super.compare(viewer, e1, e2);
		}

	}
}
