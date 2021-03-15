package info.scce.cinco.product.documentproject.views.provider;

import org.eclipse.emf.ecore.EObject;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import info.scce.cinco.product.documentproject.dependency.dependency.Dependency;
import info.scce.cinco.product.documentproject.views.nodes.ContainerTreeNode;
import info.scce.cinco.product.documentproject.views.nodes.TreeNode;
import info.scce.cinco.product.documentproject.views.utils.GraphModelUtils;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.ecore.EObject;

import graphmodel.GraphModel;

public abstract class MainTreeProvider extends TreeProvider {
		
	protected GraphModelUtils utils;

	public enum ModelType {
		Dependency
	};

	public MainTreeProvider() {
		super();
		initAllowedModels();
	}

	protected HashMap<ModelType, List<ModelType>> allowedModels = new HashMap<ModelType, List<ModelType>>();

	protected HashMap<EObject, IResource> modelToResource = new HashMap<EObject, IResource>();
	protected HashMap<IResource, EObject> resourceToModel = new HashMap<IResource, EObject>();
	protected HashMap<String, ArrayList<EObject>> modelReferencedIn = new HashMap<String, ArrayList<EObject>>();

	protected boolean showReferencedInInfo = false;

	public GraphModelUtils getUtils() {
		return utils;
	}

	public HashMap<EObject, IResource> getModelToResource() {
		return modelToResource;
	}

	public EObject getEObjectForResource(IResource res) {
		return resourceToModel.get(res);
	}

	public HashMap<ModelType, List<ModelType>> getAllowedModels() {
		return allowedModels;
	}

	public boolean isShowReferencedInInfo() {
		return showReferencedInInfo;
	}

	public void setShowReferencedInInfo(boolean showReferencedInInfo) {
		this.showReferencedInInfo = showReferencedInInfo;
	}

	protected void initAllowedModels() {
//		ArrayList<ModelType> guiModels = new ArrayList<UICompTreeProvider.ModelType>();
//		guiModels.add(ModelType.GUI);
//		guiModels.add(ModelType.GUIPLUGIN);
//		allowedModels.put(ModelType.GUI, guiModels);
//
//		ArrayList<ModelType> searchModels = new ArrayList<UICompTreeProvider.ModelType>();
//		allowedModels.put(ModelType.SEARCH, searchModels);
//
//		ArrayList<ModelType> siblibModels = new ArrayList<UICompTreeProvider.ModelType>();
//		allowedModels.put(ModelType.SIBLIBRARY, siblibModels);
//
//		ArrayList<ModelType> guiPluginModels = new ArrayList<UICompTreeProvider.ModelType>();
//		allowedModels.put(ModelType.GUIPLUGIN, guiPluginModels);
//
//		ArrayList<ModelType> processModels = new ArrayList<UICompTreeProvider.ModelType>();
//		processModels.add(ModelType.SEARCH);
//		processModels.add(ModelType.GUI);
//		processModels.add(ModelType.SIBLIBRARY);
//		processModels.add(ModelType.PROCESS);
//		processModels.add(ModelType.PROCESS_LONGRUNNING);
//		processModels.add(ModelType.PROCESS_BASIC);
//		processModels.add(ModelType.PROCESS_SECURITY);
//		allowedModels.put(ModelType.PROCESS, processModels);
//
//		ArrayList<ModelType> processBasicModels = new ArrayList<UICompTreeProvider.ModelType>();
//		processBasicModels.add(ModelType.SEARCH);
//		processBasicModels.add(ModelType.SIBLIBRARY);
//		processBasicModels.add(ModelType.PROCESS_LONGRUNNING);
//		processBasicModels.add(ModelType.PROCESS_BASIC);
//		processBasicModels.add(ModelType.PROCESS_SECURITY);
//		allowedModels.put(ModelType.PROCESS_BASIC, processBasicModels);
//
//		ArrayList<ModelType> processLongrunningModels = new ArrayList<UICompTreeProvider.ModelType>();
//		processLongrunningModels.add(ModelType.SEARCH);
//		processLongrunningModels.add(ModelType.SIBLIBRARY);
//		processLongrunningModels.add(ModelType.PROCESS_LONGRUNNING);
//		processLongrunningModels.add(ModelType.PROCESS_BASIC);
//		processLongrunningModels.add(ModelType.PROCESS_SECURITY);
//		allowedModels.put(ModelType.PROCESS_LONGRUNNING,
//				processLongrunningModels);
//
//		ArrayList<ModelType> processSecurityModels = new ArrayList<UICompTreeProvider.ModelType>();
//		processSecurityModels.add(ModelType.SEARCH);
//		processSecurityModels.add(ModelType.SIBLIBRARY);
//		processSecurityModels.add(ModelType.PROCESS_LONGRUNNING);
//		processSecurityModels.add(ModelType.PROCESS_BASIC);
//		processSecurityModels.add(ModelType.PROCESS_SECURITY);
//		allowedModels.put(ModelType.PROCESS_SECURITY, processSecurityModels);
	}

	public ModelType mapEObjectToType(EObject obj) {
		if (obj instanceof Dependency)
			return ModelType.Dependency;
		
		return null;
	}

	protected String getNameForModelType(ModelType type) {
		switch (type) {
		case Dependency:
			return "Dependency";
		
		default:
			return "unknown modeltype";
		}
	}

	protected List<Object> getDirectChilds(IContainer container) {
		ArrayList<Object> contents = new ArrayList<>();

		try {
			for (IResource res : container.members()) {
				if (utils.isModelResource(res)) {
					for (IResource modelRes : resourceToModel.keySet()) {
						if (res.equals(modelRes))
							contents.add(resourceToModel.get(modelRes));
					}
				}

				if (res instanceof IFolder)
					if (utils.hasModelResource((IContainer) res))
						contents.add(res);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}

		return contents;
	}

	protected void buildReferencedInSubTree(Object obj, TreeNode parentNode) {
		if (obj instanceof GraphModel == false)
			return;
		GraphModel gModel = (GraphModel) obj;
		if (modelReferencedIn.get(gModel.getId()) == null)
			return;
		for (EObject eObj : modelReferencedIn.get(gModel.getId())) {
			TreeNode node = new ContainerTreeNode(eObj, eObj.toString());
			if (parentNode.find(node.getId()) == null) {
				parentNode.getChildren().add(node);
				node.setParent(parentNode);
			}
		}
	}
}
