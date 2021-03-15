package info.scce.cinco.product.documentproject.template.hooks;

import java.util.ArrayList;

import de.jabc.cinco.meta.runtime.hook.CincoPreDeleteHook;
import graphmodel.Container;
import graphmodel.GraphModel;
import graphmodel.Node;
import info.scce.cinco.product.documentproject.template.helper.ElementCollector;
import info.scce.cinco.product.documentproject.template.helper.LayoutHelper;
import info.scce.cinco.product.documentproject.template.template.MovableContainer;
import info.scce.cinco.product.documentproject.template.template.Panel;

public class DeleteComponentHook extends CincoPreDeleteHook<MovableContainer>{

	
	public static int V_OFFSET_MIN = 30;
	public static int H_OFFSET_MIN = 10;
	public static int H_OFFSET = 10;
	public static int V_OFFSET = 10;
	public static int WIDTH_MIN = 100;
	
	public static int SIGN_1_X = 2;
	public static int SIGN_2_X = 17;
	public static int SIGN_Y = 2;
	
	/**
	 * Layouts and reposition the components
	 * in all parent components of the deleted component
	 *
	 */
	@Override
	public void preDelete(MovableContainer cNode) {
		
		try {
			if(cNode.getContainer() !=null){
				//Set the Moving signs depending on the container
				// Position the new element
				int width = WIDTH_MIN, height= LayoutHelper.getVOff(cNode);
				height=LayoutHelper.getVerticalHeight((Container)cNode.getContainer()) - cNode.getHeight() - V_OFFSET;
				height = height<LayoutHelper.getVOff(cNode)?LayoutHelper.getVOff(cNode):height;
				width = ((Container)cNode.getContainer()).getWidth();
				LayoutHelper.resize((Container)cNode.getContainer(),width,height);
				//Resize parent Container if necessary
				layoutComponent((Container)cNode.getContainer(),cNode);						
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	/**
	 * layouts the given container mentioning the given removed container will be removed
	 * @param cContainer
	 * @param removedContainer
	 */
	private void layoutComponent(Container cContainer,Container removedContainer)
	{
		resize(cContainer,getVerticalWidth(cContainer,removedContainer)+10,getVerticalHeight(cContainer,removedContainer)+20);
		repositionContainingElementsVertical(cContainer,removedContainer);
		
		if(cContainer.getContainer() != null){
			if(!( cContainer.getContainer() instanceof GraphModel) ){
				layoutComponent((Container)cContainer.getContainer(),removedContainer);
			}
		}
	}
	
	/**
	 * Resizes the given container to fit the given width and height
	 * @param c
	 * @param width
	 * @param height
	 */
	private void resize(Container c,int width,int height)
	{
		if(c instanceof MovableContainer)
		{
			((MovableContainer) c).resize(width, height);
		}
		if(c instanceof Panel)
		{
			((Panel)c).resize(width, height);
		}
	}

	/**
	 * Returns the maximal width of all nodes placed in the given container
	 * without the width of the given removed container 
	 * @param cContainer
	 * @param removed
	 * @return
	 */
	private int getVerticalWidth(Container cContainer,Container removed){
		 int width = WIDTH_MIN;
		 for(Node node:cContainer.getAllNodes()){
			 if(node instanceof MovableContainer || node instanceof Panel){
				 if(!node.equals(removed)) {
					 if(node.getWidth() > width){
						 width = node.getWidth();
					 }
				 }
			 }
		 }
		 return width + H_OFFSET_MIN;
	}
	
	/**
	 * Returns the inner height of all nodes placed in the given container
	 * without the width of the given removed container 
	 * @param cContainer
	 * @param removed
	 * @return
	 */
	private int getVerticalHeight(Container cContainer,Container removed)
	{
		int height = LayoutHelper.getVOff(cContainer);
		for(Node n:cContainer.getAllNodes()) {
			if(n instanceof MovableContainer || n instanceof Panel){
				 if(!n.equals(removed)) {
					 	height+=(n.getHeight()+V_OFFSET);
				 }
			}
		}
		return height;
	}
	
	
	/**
	 * Repositions all nodes placed in the given container in
	 * vertical order ignoring the removed element
	 * @param cContainer
	 * @param removed
	 */
	private void repositionContainingElementsVertical(Container cContainer,Container removed){
		int y = LayoutHelper.getVOff(cContainer);
		for(Node n:ElementCollector.getElementsV(new ArrayList<Node>(cContainer.getAllNodes()))) {
			if(n instanceof MovableContainer || n instanceof Panel){
				if(!n.equals(removed)) {
					n.setY(y);
					y += V_OFFSET;
					y += n.getHeight();
				}
			}
					
		}
	}
	
	
	
}
