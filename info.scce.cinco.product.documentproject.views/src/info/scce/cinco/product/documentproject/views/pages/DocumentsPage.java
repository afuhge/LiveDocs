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
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency;
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint;
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint;
import info.scce.cinco.product.documentproject.template.template.CheckBoxField;
import info.scce.cinco.product.documentproject.template.template.ChoiceField;
import info.scce.cinco.product.documentproject.template.template.DateField;
import info.scce.cinco.product.documentproject.template.template.Field;
import info.scce.cinco.product.documentproject.template.template.NumberField;
import info.scce.cinco.product.documentproject.template.template.Panel;
import info.scce.cinco.product.documentproject.template.template.TextField;
import info.scce.cinco.product.documentproject.views.provider.DocumentsTreeProvider;
import info.scce.cinco.product.documentproject.views.provider.MainTreeProvider.ModelType;
import info.scce.cinco.product.documentproject.views.utils.MainUtils;

public class DocumentsPage extends MainPage{
	
	private DocumentsTreeProvider data = new DocumentsTreeProvider();

	private HashMap<String, Image> icons = new HashMap<>();

	private boolean showOnlyAllowedTypes = false;

	private DocumentsLabelProvider labelProvider = new DocumentsLabelProvider();
	private DocumentsNameSorter nameSorter = new DocumentsNameSorter();
	private DocumentsModelTypeFilter modelTypeFilter = new DocumentsModelTypeFilter();

	private ArrayList<ModelType> hideModelTypes = new ArrayList<DocumentsTreeProvider.ModelType>();

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
	
	public DocumentsModelTypeFilter getModelTypeFilter() {
		return modelTypeFilter;
	}


	@Override
	public void openAndHighlight(Object obj) {
		obj = getTreeNodeData(obj);
		if (obj instanceof ModelElement) {
			ModelElement me = (ModelElement) obj;
			IEditorPart editorPart = openEditor(me.getRootElement());
			
//			if (obj instanceof GraphModel) {
//				openEditor((GraphModel) obj);
//			}
			
//			if (me.getRootElement() instanceof Process) {
//				Process wrapper = data.getUtils().getProcessWrapperFromEditor(editorPart);
//				data.getUtils().highlightElement(wrapper, me.getId());
//			}
//			if (me.getRootElement() instanceof GUI) {
//				GUI wrapper = data.getUtils().getGuiWrapperFromEditor(editorPart);
//				data.getUtils().highlightElement(wrapper, me.getId());
//			}
		}
		else if (obj instanceof GraphModel) {
			openEditor((GraphModel) obj);
		}
		
	}

	@Override
	public DocumentsTreeProvider getDataProvider() {
		return data;
	}
	
	@Override
	protected void loadIcons() {
		try {
			super.loadIcons();
			icons.put("DependencyModel", new Image(MainUtils.getDisplay(), FileLocator
					.openStream(bundle,
							new Path("icons/dependency_icon.png"), true)));
			icons.put("Panel", new Image(MainUtils.getDisplay(), FileLocator
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
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 
	 */
	private class DocumentsLabelProvider extends LabelProvider {
		public String getText(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Dependency) {
				return data.getModelToResource().get(obj).getName();
			}else if (obj instanceof info.scce.cinco.product.documentproject.dependency.dependency.Panel) {
				String label = ((info.scce.cinco.product.documentproject.dependency.dependency.Panel) obj).getName();
				return label;
			}
			else if (obj instanceof FieldConstraint) {
				String label = ((FieldConstraint) obj).getLabel();
				String operator = getOperator((FieldConstraint)obj);
				String value = getConcreteValue((FieldConstraint)obj);
				return label + " " + operator + " " + value;
			}
			return "unknown";
		}
		
		private String getConcreteValue(FieldConstraint fieldConstraint) {
			if(fieldConstraint instanceof TextFieldConstraint) {
				return ((TextFieldConstraint)fieldConstraint).getValue();
			}else if(fieldConstraint instanceof NumberFieldConstraint) {
				return String.valueOf(((NumberFieldConstraint)fieldConstraint).getValue());
			}else if(fieldConstraint instanceof DateFieldConstraint) {
				return createDate((DateFieldConstraint)fieldConstraint);
			}else if(fieldConstraint instanceof ChoiceFieldConstraint) {
				return ((ChoiceFieldConstraint)fieldConstraint).getValue().get(0);
			}else if(fieldConstraint instanceof CheckBoxFieldConstraint) {
				return String.valueOf(((CheckBoxFieldConstraint)fieldConstraint).isValue());
			}else {
				return "";
			}
		}
		
		private String createDate(DateFieldConstraint constraint) {
				if(!(constraint.getDate_day().isEmpty() || constraint.getDate_year().isEmpty() || constraint.getDate_month().isEmpty())){
					return constraint.getDate_day() + "." + constraint.getDate_month() + "." + constraint.getDate_month();
				}else {
					return "";
				}
		}
	

		private String getOperator (FieldConstraint fieldConstraint) {
			if(fieldConstraint instanceof TextFieldConstraint) {
				return ((TextFieldConstraint)fieldConstraint).getOperator().getName();
			}else if(fieldConstraint instanceof NumberFieldConstraint) {
				return ((NumberFieldConstraint)fieldConstraint).getOperator().getName();
			}else if(fieldConstraint instanceof DateFieldConstraint) {
				return ((DateFieldConstraint)fieldConstraint).getOperator().getName();
			}else if(fieldConstraint instanceof ChoiceFieldConstraint) {
				return ((ChoiceFieldConstraint)fieldConstraint).getOperator().getName();
			}else if(fieldConstraint instanceof CheckBoxFieldConstraint) {
				return ((CheckBoxFieldConstraint)fieldConstraint).getOperator();
			}else {
				return "";
			}
			
		}
		
		public Image getImage(Object obj) {
			obj = getTreeNodeData(obj);
			if (obj instanceof Dependency)
				return icons.get("DependencyModel");
			if (obj instanceof info.scce.cinco.product.documentproject.dependency.dependency.Panel)
				return icons.get("Panel");
			if (obj instanceof TextFieldConstraint)
				return icons.get("TextField");
			if (obj instanceof NumberFieldConstraint)
				return icons.get("NumberField");
			if (obj instanceof DateFieldConstraint)
				return icons.get("DateField");
			
			if (obj instanceof ChoiceFieldConstraint)
				return icons.get("ChoiceField");
			if (obj instanceof CheckBoxFieldConstraint)
				return icons.get("CheckField");
			
			return null;
		}
	}
	
	
	
	private class DocumentsModelTypeFilter extends ViewerFilter {

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
	
	private class DocumentsNameSorter extends ViewerSorter {

		@Override
		public int category(Object element) {
			if (element instanceof IFolder)
				return 1;
			if (element instanceof GraphModel)
				return 2;
			if(element instanceof Panel) {
				return 3;
			}
			if (element instanceof FieldConstraint)
				return 4;
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
			
			if (e1 instanceof Dependency && e2 instanceof Dependency) {
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
			
			if (e1 instanceof FieldConstraint && e2 instanceof FieldConstraint) {
				FieldConstraint type1 = (FieldConstraint) e1;
				FieldConstraint type2 = (FieldConstraint) e2;
				return type1.getLabel().toLowerCase()
						.compareTo(type2.getLabel().toLowerCase());
			}

			return super.compare(viewer, e1, e2);
		}

	}
}
