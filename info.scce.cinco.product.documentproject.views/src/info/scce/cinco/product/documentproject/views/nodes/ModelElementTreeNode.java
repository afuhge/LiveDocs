package info.scce.cinco.product.documentproject.views.nodes;

import graphmodel.ModelElement;

public class ModelElementTreeNode extends TreeNode{

	public ModelElementTreeNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof ModelElement)
			return ((ModelElement) data).getId();
		return null;
	}
}
