package info.scce.cinco.product.documentproject.views.pages;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

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
import info.scce.cinco.product.documentproject.documents.documents.Role;
import info.scce.cinco.product.documentproject.template.template.CheckBoxField;
import info.scce.cinco.product.documentproject.template.template.ChoiceField;
import info.scce.cinco.product.documentproject.template.template.DateField;
import info.scce.cinco.product.documentproject.template.template.Field;
import info.scce.cinco.product.documentproject.template.template.NumberField;
import info.scce.cinco.product.documentproject.template.template.Panel;
import info.scce.cinco.product.documentproject.template.template.Template;
import info.scce.cinco.product.documentproject.template.template.TextField;
import info.scce.cinco.product.documentproject.views.provider.MainTreeProvider.ModelType;
import info.scce.cinco.product.documentproject.views.provider.TemplateTreeProvider;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

public class TemplatePage extends MainPage{

	private TemplateTreeProvider data = new TemplateTreeProvider();

	private HashMap<String, Image> icons = new HashMap<>();

	private boolean showOnlyAllowedTypes = false;

	private TemplateLabelProvider labelProvider = new TemplateLabelProvider();
	private TemplateNameSorter nameSorter = new TemplateNameSorter();
	private TemplateModelTypeFilter modelTypeFilter = new TemplateModelTypeFilter();

	private ArrayList<ModelType> hideModelTypes = new ArrayList<TemplateTreeProvider.ModelType>();

	/*
	 * Getter / Setter
	 */
	@Override
	public TemplateTreeProvider getDataProvider() {
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

	public TemplateModelTypeFilter getModelTypeFilter() {
		return modelTypeFilter;
	}
	
	protected void loadIcons() {
		try {
			icons.put(
					"TemplateModel",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/template_icon.png"), true)));
			icons.put(
					"Panel",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/panel.png"), true)));
			icons.put(
					"TextField",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/textField.png"), true)));
			icons.put(
					"NumberField",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/numberField.png"), true)));
			icons.put(
					"DateField",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/dateField.png"), true)));
			icons.put(
					"CheckField",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/checkboxField.png"), true)));
			icons.put(
					"ChoiceField",
					new Image(MainUtils.getDisplay(), FileLocator
							.openStream(bundle,
									new Path("icons/choiceField.png"), true)));
			
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
	private class TemplateLabelProvider extends LabelProvider {
		public String getText(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Template) {
				return data.getModelToResource().get(obj).getName();
			} else if (obj instanceof Panel) {
				String label = ((Panel) obj).getName();
				return label;
			}
			else if (obj instanceof Field) {
				String label = ((Field) obj).getLabel();
				return label;
			}
			return "unknown";
		}
		
		public Image getImage(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Template)
				return icons.get("TemplateModel");
			if (obj instanceof Panel)
				return icons.get("Panel");
			if (obj instanceof TextField)
				return icons.get("TextField");
			if (obj instanceof NumberField)
				return icons.get("NumberField");
			if (obj instanceof DateField)
				return icons.get("DateField");
			
			if (obj instanceof ChoiceField)
				return icons.get("ChoiceField");
			if (obj instanceof CheckBoxField)
				return icons.get("CheckField");
			
			return null;
		}
	}

	private class TemplateModelTypeFilter extends ViewerFilter {

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
	
	private class TemplateNameSorter extends ViewerSorter {

		@Override
		public int category(Object element) {
			if (element instanceof IFolder)
				return 1;
			if (element instanceof GraphModel)
				return 2;
			if(element instanceof Panel) {
				return 3;
			}
			if (element instanceof Field)
				return 4;
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
			
			if (e1 instanceof Template && e2 instanceof Template) {
				IResource res1 = data.getModelToResource().get(e1);
				IResource res2 = data.getModelToResource().get(e2);
				return res1.getName().toLowerCase()
						.compareTo(res2.getName().toLowerCase());
			}

			if (e1 instanceof Panel && e2 instanceof Panel) {
				Panel type1 = (Panel) e1;
				Panel type2 = (Panel) e2;
				return type1.getName().toLowerCase()
						.compareTo(type2.getName().toLowerCase());
			}
			
			if (e1 instanceof Field && e2 instanceof Field) {
				Field type1 = (Field) e1;
				Field type2 = (Field) e2;
				return type1.getLabel().toLowerCase()
						.compareTo(type2.getLabel().toLowerCase());
			}

			return super.compare(viewer, e1, e2);
		}

	}

}
