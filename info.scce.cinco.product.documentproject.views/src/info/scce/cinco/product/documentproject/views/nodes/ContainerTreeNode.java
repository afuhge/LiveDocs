package info.scce.cinco.product.documentproject.views.nodes;

public class ContainerTreeNode extends TreeNode {

private String name;
	
	public ContainerTreeNode(Object data, String name) {
		super(data);
		this.name = name;
	}

	@Override
	public String getId() {
		return name;
	}


}
