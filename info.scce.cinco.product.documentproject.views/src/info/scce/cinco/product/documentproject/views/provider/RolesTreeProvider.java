package info.scce.cinco.product.documentproject.views.provider;

import java.util.HashMap;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.ecore.EObject;

import info.scce.cinco.product.documentproject.dependency.dependency.Dependency;
import info.scce.cinco.product.documentproject.documents.documents.Documents;
import info.scce.cinco.product.documentproject.documents.documents.Role;
import info.scce.cinco.product.documentproject.views.nodes.ContainerTreeNode;
import info.scce.cinco.product.documentproject.views.nodes.GraphModelTreeNode;
import info.scce.cinco.product.documentproject.views.nodes.ModelElementTreeNode;
import info.scce.cinco.product.documentproject.views.nodes.TreeNode;
import info.scce.cinco.product.documentproject.views.utils.RoleUtils;

import java.util.Arrays;
import java.util.HashMap;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.ecore.EObject;

public class RolesTreeProvider extends MainTreeProvider{
	private String[] fileExtensions = { "documents" };

	public enum ViewType {
		FLAT, HIERARCHY
	}

	private HashMap<EObject, IResource> modelToResource = null;

	private ContainerTreeNode flatRoot;
	private ContainerTreeNode hierarchyRoot;

	private ViewType activeView = ViewType.FLAT;
	private RoleUtils utils;

	public RolesTreeProvider() {
		super();
		this.utils = new RoleUtils(fileExtensions);
	}

	@Override
	public TreeNode getTree() {
		switch (activeView) {
		case HIERARCHY:
			return hierarchyRoot;
		case FLAT:
		default:
			return flatRoot;
		}
	}

	public String[] getFileExtensions() {
		return fileExtensions;
	}

	public RoleUtils getUtils() {
		return utils;
	}

	public HashMap<EObject, IResource> getModelToResource() {
		return modelToResource;
	}

	public ViewType getActiveView() {
		return activeView;
	}

	public void setActiveView(ViewType activeView) {
		this.activeView = activeView;
	}

	@Override
	public void loadData(IProject project) {
		final long timeStart = System.currentTimeMillis();
		modelToResource = new HashMap<>();
		if (project == null)
			return;
		try {
			for (IResource iResource : project.members()) {
				loadContentModels(iResource);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		final long timeLoad = System.currentTimeMillis();
		
		switch (activeView) {
		case HIERARCHY:
			hierarchyRoot = new ContainerTreeNode(null, "root");
			for (EObject model : modelToResource.keySet()) {
				buildHierarchyTree(model, hierarchyRoot);
			}
			break;
		case FLAT:
		default:
			flatRoot = new ContainerTreeNode(null, "root");
			for (EObject model : modelToResource.keySet()) {
				buildFlatTree(model, flatRoot);
			}
			break;
		}
		final long timeBuild = System.currentTimeMillis();
		
		System.out.println("DataCompView - load Models: " + (timeLoad-timeStart) + " ms / create Tree: " + (timeBuild-timeLoad) + " ms");
	}

	@SuppressWarnings("restriction")
	private void loadContentModels(IResource iResource) {
		if (iResource instanceof org.eclipse.core.internal.resources.File)
			if (Arrays.asList(fileExtensions).contains(
					iResource.getFileExtension())) {
				EObject model = utils.loadModel(iResource);
				modelToResource.put(model, iResource);
			}

		if (iResource instanceof org.eclipse.core.internal.resources.Folder)
			try {
				for (IResource subRes : ((org.eclipse.core.internal.resources.Folder) iResource)
						.members()) {
					loadContentModels(subRes);
				}
			} catch (CoreException e) {
				e.printStackTrace();
			}
	}

	private TreeNode buildFlatTree(Object obj, TreeNode parentNode) {
		TreeNode node = new ContainerTreeNode(null, "dummy");

		/*
		 * data model
		 */
		if (obj instanceof Documents) {
			node = new GraphModelTreeNode(obj, modelToResource.get(obj));
			if (((Documents) obj).getRoles().size() <= 0)
				return node;
			for (Role type : ((Documents) obj).getRoles()) {
				buildFlatTree(type, node);
			}
		}

		if (obj instanceof Role) {
			node = new ModelElementTreeNode(obj);
			//return node;
		}
			/*
		 * post processing
		 */
		TreeNode existingNode = parentNode.find(node.getId());
		if (existingNode == null) {
			parentNode.getChildren().add(node);
			node.setParent(parentNode);
		} else {
			return existingNode;
		}
		return node;
	}

	private TreeNode buildHierarchyTree(Object obj, TreeNode parentNode,
			boolean buildParent) {
		TreeNode node = new ContainerTreeNode(null, "dummy");

		/*
		 * data model
		 */
		if (obj instanceof Documents) {
			node = new GraphModelTreeNode(obj, modelToResource.get(obj));
			if (((Documents) obj).getRoles().size() <= 0)
				return node;
			for (Role type : utils.getRoles((Documents) obj)) {
				buildHierarchyTree(type, node);
			}
		}
		if (obj instanceof Role) {
			node = new ModelElementTreeNode(obj);
		}
		/*
		 * post processing
		 */
		TreeNode existingNode = parentNode.find(node.getId());
		if (existingNode == null) {
			parentNode.getChildren().add(node);
			node.setParent(parentNode);
		} else {
			return existingNode;
		}
		return node;
	}

	private TreeNode buildHierarchyTree(Object obj, TreeNode parentNode) {
		return buildHierarchyTree(obj, parentNode, false);
	}
	


}
