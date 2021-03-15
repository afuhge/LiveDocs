package info.scce.cinco.product.documentproject.template.hooks;

import de.jabc.cinco.meta.runtime.hook.CincoPostMoveHook;
import graphmodel.Container;
import graphmodel.ModelElementContainer;
import graphmodel.Node;
import info.scce.cinco.product.documentproject.template.helper.LayoutHelper;
import info.scce.cinco.product.documentproject.template.template.MovableContainer;

public class MoveComponentHook extends CincoPostMoveHook<MovableContainer> {

	/**
	 * Resizes and layouts the previous and the new parent component of the moved
	 * component
	 */
	public void postMove(MovableContainer modelElement, ModelElementContainer sourceContainer,
			ModelElementContainer targetContainer, int x, int y, int deltaX, int deltaY) {

		if (!(modelElement instanceof Node))
			return;
		try {
			Node cNode = (Node) modelElement;
			int newx = x;
			int newy = y;
			// Set Position
			if (cNode.getContainer() != null) {
				newx = LayoutHelper.H_OFFSET_MIN;
				cNode.setX(newx);
				cNode.setY(newy);
				// Resize parent Container if necessary
				if (cNode.getContainer() instanceof Container) {
					LayoutHelper.layoutComponent((Container) sourceContainer);
					LayoutHelper.layoutComponent((Container) targetContainer);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
