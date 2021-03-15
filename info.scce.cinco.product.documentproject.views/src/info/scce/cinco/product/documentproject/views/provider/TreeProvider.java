package info.scce.cinco.product.documentproject.views.provider;

import org.eclipse.core.resources.IProject;

import info.scce.cinco.product.documentproject.views.nodes.TreeNode;

public abstract class TreeProvider {
private boolean resetted = true;
	
	public boolean isResetted() {
		return resetted;
	}

	public void reset() {
		resetted = true;
	}
	
	public void load(IProject project) {
		resetted = false;
		loadData(project);
	}

	abstract public void loadData(IProject project);
	
	abstract public TreeNode getTree();
}
