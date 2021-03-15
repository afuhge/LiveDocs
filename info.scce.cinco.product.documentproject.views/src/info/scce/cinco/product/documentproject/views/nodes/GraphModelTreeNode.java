package info.scce.cinco.product.documentproject.views.nodes;

import org.eclipse.core.resources.IResource;

import graphmodel.GraphModel;

public class GraphModelTreeNode extends TreeNode{
private IResource resource;
	
	public GraphModelTreeNode(Object data, IResource resource) {
		super(data);

		this.resource = resource;
	}

	public IResource getResource() {
		return resource;
	}

	@Override
	public String getId() {
		if (data instanceof GraphModel)
			return ((GraphModel) data).getId();
		return resource.getName();
	}
}
