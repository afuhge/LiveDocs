package info.scce.cinco.product.documentproject.template.helper;

import java.util.ArrayList;

import graphmodel.Container;
import graphmodel.Node;
import info.scce.cinco.product.documentproject.template.template.MovableContainer;
import info.scce.cinco.product.documentproject.template.template.Panel;
import info.scce.cinco.product.documentproject.template.template.Template;

public class LayoutHelper {
	
	public static int V_OFFSET_MIN = 30;
	public static int H_OFFSET_MIN = 10;
	public static int H_OFFSET = 10;
	public static int V_OFFSET = 10;
	public static int HEIGHT_MIN = 60;
	public static int WIDTH_MIN = 100;
	

	/**
	 * Checks if the given container is the root template
	 * 
	 * @param cContainer
	 * @return
	 */
	private static boolean isRootComponent(Container cContainer) {
		return !(cContainer.getContainer() instanceof Template);
	}

	/**
	 * Layouts the elements in the given container and all its parent container
	 * until the root template
	 * 
	 * @param cContainer
	 */
	public static void layoutComponent(Container cContainer) {
		resize(cContainer, getVerticalWidth(cContainer) + 10, getVerticalHeight(cContainer) + 20);
		repositionContainingElementsVertical(cContainer);
		if (cContainer.getContainer() != null) {
			if (isRootComponent(cContainer)) {
				layoutComponent((Container) cContainer.getContainer());
			}
		}
	}

	/**
	 * Returns the component specific height
	 * 
	 * @param c
	 * @return
	 */
	public static int getVOff(Container c) {
		return V_OFFSET_MIN;
	}

	/**
	 * Returns the summed width of all nodes placed in the given container which are
	 * wider than the given node
	 * 
	 * @param cc
	 * @param node
	 * @return
	 */
	public static int getHorizontalWidth(Container cc, Node node) {
		int x = LayoutHelper.H_OFFSET_MIN;
		for (Node n : ElementCollector.getElementsH(getAllNodes(cc))) {
			if (n.getX() < node.getX()) {
				x += n.getWidth() + LayoutHelper.H_OFFSET;
			}
		}
		return x;
	}

	/**
	 * Returns the summed height of all nodes placed in the given container which
	 * are taller than the given node
	 * 
	 * @param cc
	 * @param node
	 * @return
	 */
	public static int getVerticalHeight(Container cc, Node node) {
		int y = LayoutHelper.getVOff(cc);
		for (Node n : ElementCollector.getElementsV(getAllNodes(cc))) {
			if (n.getY() < node.getY()) {
				y += n.getWidth() + LayoutHelper.V_OFFSET;
			}
		}
		return y;
	}

	/**
	 * Returns the maximal width of all inner nodes in the given container
	 * 
	 * @param cContainer
	 * @return
	 */
	private static int getVerticalWidth(Container cContainer) {
		int width = WIDTH_MIN;
		for (Node node : getAllNodes(cContainer)) {
			if (node.getWidth() > width) {
				width = node.getWidth();
			}
		}
		return width + H_OFFSET_MIN;
	}

	/**
	 * Returns the summed height of all nodes in the given container
	 * 
	 * @param cContainer
	 * @return
	 */
	public static int getVerticalHeight(Container cContainer) {
		int height = getVOff(cContainer);
		for (Node n : getAllNodes(cContainer)) {
			height += (n.getHeight() + V_OFFSET);
		}
		return height;
	}

	/**
	 * Returns the summed width of all nodes in the given container
	 * 
	 * @param cContainer
	 * @return
	 */
	public static int getHorizontalWidth(Container cContainer) {
		int width = H_OFFSET_MIN;
		for (Node n : getAllNodes(cContainer)) {
			width += (n.getWidth() + H_OFFSET);
		}
		if (width < WIDTH_MIN)
			width = WIDTH_MIN;
		return width;
	}

	/**
	 * Repositions the nodes in the given container vertical
	 * 
	 * @param cContainer
	 */
	private static void repositionContainingElementsVertical(Container cContainer) {

		int y = getVOff(cContainer);
		for (Node n : ElementCollector.getElementsV(getAllNodes(cContainer))) {
			n.setY(y);
			y += V_OFFSET;
			y += n.getHeight();
		}
	}

	/**
	 * Resizes the given node to the defined width and height
	 * 
	 * @param cNode
	 * @param width
	 * @param height
	 */
	public static void resize(Node cNode, int width, int height) {
		if (cNode instanceof MovableContainer) {
			((MovableContainer) cNode).resize(width, height);
		}
		if (cNode instanceof Panel) {
			((Panel) cNode).resize(width, height);
		}
	}

	/**
	 * Returns a list of all nodes in the give container
	 * 
	 * @param cContainer
	 * @return
	 */
	public static ArrayList<Node> getAllNodes(Container cContainer) {
		ArrayList<Node> nodes = new ArrayList<Node>();
		for (Node cNode : cContainer.getAllNodes()) {
			nodes.add(cNode);
		}
		return nodes;
	}
	
	
}
