package info.scce.cinco.product.documentproject.views.nodes;

import org.eclipse.core.resources.IResource;

import graphmodel.GraphModel;
import graphmodel.ModelElement;

public class PrimeTreeNode extends GraphModelTreeNode{
	private ModelElement element;
	private GraphModel model;

	public PrimeTreeNode(ModelElement element, GraphModel model, IResource resource) {
		super(element, resource);
		this.element = element;
		this.model = model;
	}
	
	public ModelElement getElement() {
		return element;
	}

	public GraphModel getModel() {
		return model;
	}

	@Override
	public String getId() {
		return element.getId() + "-" + model.getId();
	}

}
