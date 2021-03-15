package info.scce.cinco.product.documentproject.template.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook
import graphmodel.Container
import graphmodel.Node
import info.scce.cinco.product.documentproject.template.factory.TemplateFactory
import info.scce.cinco.product.documentproject.template.template.Field
import info.scce.cinco.product.documentproject.template.template.MovableContainer
import info.scce.cinco.product.documentproject.template.template.Panel
import info.scce.cinco.product.documentproject.template.helper.LayoutHelper
import info.scce.cinco.product.documentproject.template.template.BaseElement

class CreateComponentHook extends CincoPostCreateHook<Node>{
	
	public static int V_OFFSET_MIN = 30;
	public static int H_OFFSET_MIN = 10;
	
	/**
	 * Positions the new create GUI model component
	 * depended on the parent component type and whether its child components are
	 * positioned in horizontal or vertical order.
	 * In addition to this, the new component is prepared with default values.
	 */
	
	override void postCreate(Node node) {
		
		try {
			if(forbiddenNode(node)){
				if(node instanceof BaseElement){
					var BaseElement cb =node as BaseElement;
					cb.delete();
					return;
				}
			}
			
			//Set Position
			if(node.getContainer() !=null){
				if(node.getContainer() instanceof Container){
					// Position the new element
					var x = node.getX();
					var y = node.getY();
					x = H_OFFSET_MIN;
					node.setX(x);
					node.setY(y);
					//Resize parent Container if necessary
					if(node.getContainer() instanceof Container){
						LayoutHelper.layoutComponent(node.getContainer() as Container);
					}
				}
			}
			addStaticContent(node as Container);
			addSubmitButton(node as Container)
			if(node instanceof Panel){
				var panel = node as Panel
				panel.name = panel.name
			}
	
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * Checks, if the created node is not allowed in GUI models
	 * and deletes it.
	 * @param node
	 * @return
	 */
	def boolean forbiddenNode(Node node) {
		return false;
	}

	/**
	 * Adds static content to the container depended on its type
	 * @param cContainer
	 */
	def void addStaticContent(Container cContainer)
	{
		if(cContainer instanceof Panel) {
			var Panel t = cContainer as Panel;
			t.name = "MyHeadline"
		}
	}
		
	def addSubmitButton(Container container) {
		if(container instanceof Panel){
			var panel = container as Panel
			panel.newButton(5, panel.height-80, 190, 60)
		}
	}
}